# Sample for adding text to an image

Works on **.NET 10** (including Linux containers). Uses ImageSharp 3.x + ImageSharp.Drawing 2.x.

On Linux, `Verdana` is often missing; the helper falls back to DejaVu / Liberation / Arial, then the first installed family.

Usage:

```csharp
var renderedImage = ImageHelper.AddTextToImage(
    imgStream,
    ("What do you call a developer who doesn't comment code?", (10, 10), 32, "ffffff"),
    ("A developer", (10, 44), 24, "000000"));
```
