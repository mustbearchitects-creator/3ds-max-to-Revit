# 3ds-max-to-Revit
# Export to Revit — 3ds Max Plugin

A MAXScript plugin for 3ds Max 2023–2026 that exports selected 3D objects to Revit-compatible DXF or OBJ files. Splits geometry by material ID, auto-optimizes heavy meshes, and centers geometry to world origin.

---

## Features

- Splits geometry by material ID into separate DXF/OBJ layers
- Auto-optimizes meshes with more than 32,000 faces using ProOptimizer
- Centers geometry to world origin (XY center, Z bottom = 0)
- Supports 3ds Max groups — export each group as a separate file
- BBox-based grouping for objects that intersect or touch
- Interactive layer naming before export — select objects by layer to preview
- Exports to DXF or OBJ format
- Remembers last save path within session

---

## Requirements

- Autodesk 3ds Max 2023 or later
- No additional plugins required

---

## Installation

1. Download `My3dsMaxToRevit.ms`

2. Copy the file to your 3ds Max scripts folder:
   C:\Program Files\Autodesk\3ds Max 2026\scripts\
 > Replace `2026` with your 3ds Max version year

3. Open 3ds Max (or restart if already open)

4. Run the script via **MAXScript → Run Script** and select `My3dsMaxToRevit.ms`

5. The plugin panel will open automatically

### Optional: Add to Toolbar

To add a permanent button to your toolbar:

1. After running the script at least once, go to **Customize → Customize User Interface**
2. In the **Toolbars** tab, find category **MUSTBE Tools**
3. Drag **my3dmaxtoRev** onto any toolbar

> **Tip:** To run the script automatically on startup, copy it to:
> ```
> C:\Program Files\Autodesk\3ds Max 2026\scripts\Startup\
> ```
> This way the toolbar button will always be available without manually running the script each time.

---

## Usage
<img width="324" height="547" alt="image" src="https://github.com/user-attachments/assets/b690229a-83d6-4a15-9f23-751b9275bc58" />

### Basic Export

1. Select the objects you want to export
2. Click the plugin button to open the **Export to Revit** panel
3. Enter a **Family Name** — this will be used as the filename
4. Select **Format**: DXF or OBJ
5. Set the **Save Path** using the `...` button or type it directly
6. Click **Export**

### Layer Naming Window

After clicking Export, the **Edit Layers** window opens:

- Each row shows a layer name derived from the material name
- Click a layer in the list — the objects on that layer will be **selected in the scene** so you can see what they are
- Edit the name in the **Layer name** field and click **Set Name** to rename
- When all layers are named correctly, click **Export** to save the files

### Split by BBox

Enable **Split by BBox** to automatically group objects whose bounding boxes intersect — each group is exported as a separate file named `FamilyName_ObjectName`.

### Groups as Furniture ⭐ Recommended

> **We strongly recommend using this workflow for all furniture and object exports.**

The most reliable and clean way to export multiple objects to Revit. Before exporting, organize your objects into **3ds Max Groups** — one group per furniture piece or object family.

Assign the names of your future families to the groups.

Enable **Groups as Furniture** to treat each 3ds Max group as a separate export file:
- Each group → one file named after the group
- Objects not in any group → combined into one file named after the Family Name
- Nested groups are automatically dissolved

### Combining Both Options

| Split by BBox | Groups as Furniture | Result |
|:---:|:---:|---|
| ☐ | ☐ | All selected objects → one file |
| ✓ | ☐ | Objects split by intersecting bounding boxes → separate files |
| ☐ | ✓ | Groups → separate files, singles → one file |
| ✓ | ✓ | Groups → separate files, singles → split by BBox |

---

## Notes

- Objects with more than **32,000 faces** are automatically optimized with ProOptimizer before export
- All exported geometry is moved so that **XY center = 0,0** and **bottom Z = 0** — ready for Revit family import
- Geometry is split by **Material ID**, so make sure materials are properly assigned before export
- The plugin uses **Ctrl+Z** (undo) to revert all scene changes after export

---

## Compatibility

| 3ds Max Version | Status |
|---|---|
| 2023 | ✅ Tested |
| 2024 | ✅ Tested |
| 2026 | ✅ Tested |

---

## License

MIT License — free to use and modify.

---

## Author

Developed by Aleksei Volkov (https://www.instagram.com/volkov_alex_/).
