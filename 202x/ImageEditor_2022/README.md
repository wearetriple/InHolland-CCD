# Sample for adding text to File

usage

```
var renderedImageBytes = ImageHelper.AddTextToImage(imageBytes, 
                ("What do you call a developer who doesn't comment code?", (10, 10), 32, "ffffff"),
                ("A developer", (10, 44), 24, "000000")
                );

var (editedImage, colors) = ImageHelper.EditImage(imageBytes, 3);
```