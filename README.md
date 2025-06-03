# Media Date Fixer

A simple, interactive PowerShell utility to batch-set or fix the creation date metadata of photo and video files using ExifTool.

---

## What is Media Date Fixer?

Media Date Fixer scans a folder for image or video files, extracts the correct creation date and time from the file name (e.g.,  
`Photo 23-12-16 23-30-08.jpg`,  
`Screenshot 2025-06-03 235938.png`,  
`Video 23-12-16 23-30-08.mp4`),  
and writes this date into the file's metadata using [ExifTool](https://exiftool.org/).  
Processed files are copied to a destination folder.  
This is especially helpful for restoring missing or incorrect metadata after exports from cloud services, WhatsApp, Windows/Android screenshots, or photo moves.

---

## Features

- Interactive CLI: no need to edit the script, just run and follow prompts
- Supports images: **JPG, JPEG, TIFF, PNG**
- Supports videos: **MP4, MOV, M4V**
- Recognizes file name patterns:  
  - `Photo YY-MM-DD HH-MM-SS*`
  - `Screenshot YYYY-MM-DD HHMMSS*`
  - `Video YY-MM-DD HH-MM-SS*`
- Writes the extracted date to all relevant metadata fields using ExifTool
- Optionally copies even files that already contain a creation date, or only those missing it
- Clear logging of all actions

---

## Requirements

- **Windows with PowerShell**
- **[ExifTool](https://exiftool.org/)** must be downloaded and accessible (just unzip the download, no install required)
- Basic familiarity with folders and file paths

---

## Usage

1. **Download ExifTool:**  
   - Get it from [exiftool.org](https://exiftool.org/)  
   - Unpack the zip and note the full path to `exiftool.exe`
2. **Download or clone this script:**  
   - Save as `media-date-fixer.ps1`
3. **Run the script in PowerShell:**  
   - Right-click > "Run with PowerShell"  
   - *or* in a PowerShell window:
     ```powershell
     .\media-date-fixer.ps1
     ```
4. **Follow the prompts:**  
   - Enter the full path to exiftool.exe
   - Choose image or video mode
   - Specify source and destination folders
   - Decide whether already-dated files should be copied or skipped

---

## License

This project is licensed under the MIT License – see the [LICENSE](LICENSE) file for details.

---

## Acknowledgements

- [ExifTool by Phil Harvey](https://exiftool.org/)
- Inspired by personal needs to restore metadata for exported and backed-up photos/videos.
