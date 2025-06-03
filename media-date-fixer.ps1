Write-Host ""
Write-Host "====================================================="
Write-Host "        Media Date Fixer Utility"
Write-Host "(For Photos: JPG, JPEG, TIFF, PNG — Videos: MP4, MOV, M4V)"
Write-Host "Author: AndaPlays | License: MIT | https://github.com/andaplays/media-date-fixer"
Write-Host ""
Write-Host "What does this script do?"
Write-Host "- Scans a folder for image or video files"
Write-Host "- Extracts date & time from filenames like:"
Write-Host "      Photo 23-12-16 23-30-08.jpg"
Write-Host "      Screenshot 2025-06-03 235938.png"
Write-Host "      Video 23-12-16 23-30-08.mp4"
Write-Host "- Writes the correct creation date into the file's metadata"
Write-Host "- Processed files are copied to your destination folder"
Write-Host ""
Write-Host "You will now be prompted for:"
Write-Host "1) The full path to exiftool.exe"
Write-Host "2) The mode: Images or Videos"
Write-Host "3) The source folder (where files are read from)"
Write-Host "4) The destination folder (where files will be copied to)"
Write-Host "5) Whether to also copy files that already have a date"
Write-Host ""
Write-Host "Please make sure exiftool.exe is downloaded and accessible!"
Write-Host "====================================================="
Write-Host ""

# Prompt for ExifTool path
$exifToolPath = Read-Host "Enter full path to exiftool.exe (e.g. C:\Users\Anda\Downloads\exiftool-12.99_64\exiftool.exe)"

# Prompt for mode: Images or Videos
$mode = Read-Host "Which mode do you want? (I = Images / V = Videos)"

# Prompt for source and destination folder
$sourceFolder = Read-Host "Enter source folder (e.g. C:\Users\Anda\Downloads\old_photos)"
$destinationFolder = Read-Host "Enter destination folder (e.g. C:\Users\Anda\Downloads\new_photos)"

# Ask if files with existing date metadata should also be copied
$copyDated = Read-Host "Should files that already have a date be copied anyway? (Y/N)"

# Create destination folder if not present
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

function Get-DateTimeFromFileName {
    param([string]$fileName, [string]$ext)

    # Photo YY-MM-DD HH-MM-SS
    if ($fileName -match "Photo (\d{2})-(\d{2})-(\d{2}) (\d{2})-(\d{2})-(\d{2})") {
        $year = "20$($matches[1])"
        $month = $matches[2]
        $day = $matches[3]
        $hour = $matches[4]
        $minute = $matches[5]
        $second = $matches[6]
        $dateTimeExif = "${year}:${month}:${day} ${hour}:${minute}:${second}"
        $dateTimeIso = "${year}-${month}-${day}T${hour}:${minute}:${second}"
        return @{Exif=$dateTimeExif; ISO=$dateTimeIso}
    }
    # Screenshot YYYY-MM-DD HHMMSS
    elseif ($fileName -match "Screenshot (\d{4})-(\d{2})-(\d{2}) (\d{2})(\d{2})(\d{2})") {
        $year = $matches[1]
        $month = $matches[2]
        $day = $matches[3]
        $hour = $matches[4]
        $minute = $matches[5]
        $second = $matches[6]
        $dateTimeExif = "${year}:${month}:${day} ${hour}:${minute}:${second}"
        $dateTimeIso = "${year}-${month}-${day}T${hour}:${minute}:${second}"
        return @{Exif=$dateTimeExif; ISO=$dateTimeIso}
    }
    else {
        return $null
    }
}

if ($mode -eq "I" -or $mode -eq "i") {
    # --- Image Mode ---
    $supportedImageExtensions = @("*.jpg", "*.jpeg", "*.tif", "*.tiff", "*.png")
    foreach ($extension in $supportedImageExtensions) {
        Get-ChildItem -Path $sourceFolder -Filter $extension | ForEach-Object {
            $file = $_
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $ext = $file.Extension.ToLower()

            # Check if metadata already exists
            $hasDateTimeOriginal = & "$exifToolPath" -DateTimeOriginal -s -s -s "$($file.FullName)"
            $hasCreationTime = & "$exifToolPath" -CreationTime -s -s -s "$($file.FullName)"

            $dateInfo = Get-DateTimeFromFileName $fileName $ext

            if (
                ($ext -in @(".jpg", ".jpeg", ".tif", ".tiff") -and -not $hasDateTimeOriginal -and $dateInfo) -or
                ($ext -eq ".png" -and -not $hasCreationTime -and $dateInfo)
            ) {
                # Write metadata
                if ($ext -eq ".png") {
                    & "$exifToolPath" "-CreationTime=$($dateInfo.ISO)" "-o" "$destinationFolder\$($file.Name)" "$($file.FullName)"
                    Write-Output "Added CreationTime and copied: $($file.Name)"
                } else {
                    & "$exifToolPath" "-DateTimeOriginal=$($dateInfo.Exif)" "-CreateDate=$($dateInfo.Exif)" "-ModifyDate=$($dateInfo.Exif)" `
                        "-o" "$destinationFolder\$($file.Name)" "$($file.FullName)"
                    Write-Output "Added DateTimeOriginal and copied: $($file.Name)"
                }
            }
            elseif ($dateInfo -eq $null) {
                Write-Output "Skipped (invalid filename format): $($file.Name)"
            }
            elseif (($ext -in @(".jpg", ".jpeg", ".tif", ".tiff") -and $hasDateTimeOriginal) -or
                    ($ext -eq ".png" -and $hasCreationTime)) {
                if ($copyDated -eq "Y" -or $copyDated -eq "y") {
                    Copy-Item -Path "$($file.FullName)" -Destination "$destinationFolder\$($file.Name)"
                    Write-Output "Skipped (date already set, copied anyway): $($file.Name)"
                } else {
                    Write-Output "Skipped (date already set, not copied): $($file.Name)"
                }
            }
        }
    }
}
elseif ($mode -eq "V" -or $mode -eq "v") {
    # --- Video Mode ---
    $supportedVideoExtensions = @("*.mp4", "*.mov", "*.m4v")
    foreach ($extension in $supportedVideoExtensions) {
        Get-ChildItem -Path $sourceFolder -Filter $extension | ForEach-Object {
            $file = $_
            $fileName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
            $ext = $file.Extension.ToLower()

            $dateInfo = $null
            # Accepts both Photo and Screenshot patterns in video mode for completeness
            if ($fileName -match "^(Video|Photo) (\d{2})-(\d{2})-(\d{2}) (\d{2})-(\d{2})-(\d{2})") {
                $year = "20$($matches[2])"
                $month = $matches[3]
                $day = $matches[4]
                $hour = $matches[5]
                $minute = $matches[6]
                $second = $matches[7]
                $dateInfo = @{
                    Exif = "${year}:${month}:${day} ${hour}:${minute}:${second}"
                }
            }

            if ($dateInfo) {
                & "$exifToolPath" `
                    "-MediaCreateDate=$($dateInfo.Exif)" `
                    "-CreateDate=$($dateInfo.Exif)" `
                    "-ModifyDate=$($dateInfo.Exif)" `
                    "-QuickTime:CreationDate=$($dateInfo.Exif)" `
                    "-TrackCreateDate=$($dateInfo.Exif)" `
                    "-TrackModifyDate=$($dateInfo.Exif)" `
                    "-MediaModifyDate=$($dateInfo.Exif)" `
                    "-overwrite_original" `
                    "$($file.FullName)"

                Copy-Item -Path "$($file.FullName)" -Destination "$destinationFolder\$($file.Name)"
                Write-Output "Set date and copied: $($file.Name)"
            } else {
                Write-Output "Skipped (invalid filename format): $($file.Name)"
            }
        }
    }
}
else {
    Write-Output "Invalid input. Please enter 'I' for images or 'V' for videos."
}
