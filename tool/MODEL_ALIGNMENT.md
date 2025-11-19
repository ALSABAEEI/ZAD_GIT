# Aligning PyTorch (.pt) and TFLite food classifiers

When Colab predictions (PyTorch) disagree with the shipped TFLite model, the only durable fix is to export the exact same weights and preprocessing pipeline into a new `.tflite` file. Use the checklist below to guarantee parity.

---

## 1. Collect the PyTorch training details

> **Current classifier (Nov 2025)**
>
> - Resize: 224×224, RGB
> - Normalize: mean = `[0.485, 0.456, 0.406]`, std = `[0.229, 0.224, 0.225]`
> - Label order: `[Burger, Donut, Pizza, Roasted Chicken, club sandwich]`
> - Checkpoint: Ultralytics YOLO11 classification `.pt` (state_dict inside `UltralyticsClassifyModel`)
> - Metadata file: `tool/food_model_metadata.json`

| Item | Why it matters | How to capture |
| --- | --- | --- |
| **Input transforms** | The TFLite pipeline must apply the same resize, crop, normalization, and channel order | Copy the `torchvision.transforms` sequence (resize, center/RandomCrop, `ToTensor`, `Normalize(mean, std)`) from your training/eval script |
| **Label order** | TFLite outputs logits in the same order you export; mismatched indices cause wrong labels | Export the list/CSV that maps model output index → class name |
| **Model checkpoint type** | Determines the correct load call | Note whether you saved via `torch.save(model.state_dict())`, full `torch.save(model)`, or `torch.jit.trace/script` |
| **Ops used** | Some PyTorch operators need opset 13+ or custom kernels in TFLite | Run `torch.onnx.export(..., opset_version=13)` and capture any warnings |

> ✅ Once you have these four nuggets, paste them into the repo (for example `tool/food_model_metadata.json`) so the app and conversion scripts can stay in sync.

---

## 2. Export the PyTorch checkpoint to ONNX

Create `tool/export_to_onnx.py` (or run ad hoc) using the template below. Update `MODEL_CLASS`, checkpoint path, image size, and normalization numbers to match your training code.

```python
import argparse
from pathlib import Path

import torch

from food_model import FoodClassifier  # replace with your model class

MEAN = (0.485, 0.456, 0.406)  # example
STD = (0.229, 0.224, 0.225)
IMG_SIZE = 224


def load_model(pt_path: Path) -> torch.nn.Module:
    model = FoodClassifier()
    state = torch.load(pt_path, map_location="cpu")
    if isinstance(state, dict) and "state_dict" in state:
        state = {k.replace("model.", ""): v for k, v in state["state_dict"].items()}
    model.load_state_dict(state)
    model.eval()
    return model


def main(args):
    model = load_model(Path(args.checkpoint))
    dummy = torch.randn(1, 3, IMG_SIZE, IMG_SIZE)
    torch.onnx.export(
        model,
        dummy,
        args.onnx,
        input_names=["input"],
        output_names=["logits"],
        opset_version=13,
        dynamic_axes={"input": {0: "batch"}, "logits": {0: "batch"}},
    )
    print(f"Exported ONNX to {args.onnx}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--checkpoint", required=True)
    parser.add_argument("--onnx", default="food_classifier.onnx")
    main(parser.parse_args())
```

Verify the ONNX graph with `onnx.checker.check_model(...)` or the Netron viewer to ensure the tensor order matches expectations (channels-first → NHWC conversion happens in the next step).

---

## 3. Convert ONNX → TensorFlow → TFLite

Assuming you have Python 3.10+ with `tensorflow`, `onnx`, and `onnx_tf` installed:

```python
import onnx
from onnx_tf.backend import prepare
import tensorflow as tf

onnx_model = onnx.load("food_classifier.onnx")
tf_rep = prepare(onnx_model)
tf_rep.export_graph("tmp_tf_graph")

converter = tf.lite.TFLiteConverter.from_saved_model("tmp_tf_graph")
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_ops = [
    tf.lite.OpsSet.TFLITE_BUILTINS,
    tf.lite.OpsSet.SELECT_TF_OPS,
]
# Optional: set converter.inference_input_type / output_type for quantization

new_tflite = converter.convert()
with open("assets/models/food_classifier.tflite", "wb") as f:
    f.write(new_tflite)
```

Tips:
- If your PyTorch preprocessing normalizes to ImageNet mean/std, mirror that inside Flutter before feeding TFLite (currently we scale 0–1). Update `_runInference` accordingly.
- For quantized models, run a representative dataset when calling `converter.representative_dataset` so activations calibrate correctly.

---

## 4. Plug the refreshed model into Flutter

1. Drop the regenerated `food_classifier.tflite` into `assets/models/`.
2. Update `_modelLabels` in `food_type_detector_native.dart` if the class order changed.
3. Match preprocessing: if the PyTorch model expects `((pixel / 255) - mean) / std`, port the exact math (per-channel) into `_runInference`.
4. Rebuild: `flutter clean && flutter run`.
5. Validate with the troublesome chicken + pizza photos while tailing the `Top predictions` logs.

---

## 5. Share the metadata

To keep future conversions painless, store the following beside the model:

```json
{
  "image_size": 224,
  "mean": [0.0, 0.0, 0.0],
  "std": [1.0, 1.0, 1.0],
  "label_order": ["Burger", "Donut", "Pizza", "Roasted Chicken", "club sandwich"]
}
```

Commit both the metadata file and the conversion script so anyone can regenerate the `.tflite` artifact and compare outputs against Colab.

---

**Next step for us:** supply the PyTorch transform + checkpoint details (or the raw `.pt` file) so we can run the export script and drop the matching `.tflite` into the app. Once we have that, the roasted-chicken photo should line up exactly with your Colab prediction.
