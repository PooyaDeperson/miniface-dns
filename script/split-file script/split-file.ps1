# ============================================
# File Chunk Splitter
# 
# Put this script in the SAME folder as the
# file you want to split.
#
# Example:
# Folder:
#   split-file.ps1
#   model.bin
#
# Run
# .\split-file.ps1 -InputFile "avatar.bin" -ChunkSizeMB 5
#
#
#
# Result:
#   Splitted/
#       model_chunk_0000.bin
#       model_chunk_0001.bin
#       model_chunk_0002.bin
#
#

# ============================================


param(
    # CHANGE THIS:
    # Put the name of the file you want to split here
    # Example: "model.bin" or "scene.glb"
    [string]$InputFile = "model.bin",


    # CHANGE THIS:
    # Chunk size in megabytes.
    # If your limit is 10 MB, keep this around 8-9 MB.
    # Example:
    # 5  = 5 MB chunks
    # 9  = 9 MB chunks
    [int]$ChunkSizeMB = 5
)


# ============================================
# Do not normally change below this line
# ============================================


# Create output folder
$outputFolder = Join-Path `
    (Split-Path -Parent $MyInvocation.MyCommand.Path) `
    "Splitted"


if (!(Test-Path $outputFolder)) {
    New-Item -ItemType Directory -Path $outputFolder | Out-Null
}


# Check that input file exists
$inputPath = Join-Path `
    (Split-Path -Parent $MyInvocation.MyCommand.Path) `
    $InputFile


if (!(Test-Path $inputPath)) {
    Write-Host "ERROR: Cannot find file:"
    Write-Host $inputPath
    exit 1
}


# Convert MB to bytes
$chunkSize = $ChunkSizeMB * 1MB


$fileInfo = Get-Item $inputPath

Write-Host ""
Write-Host "Splitting file:"
Write-Host $fileInfo.Name
Write-Host "Size:"
Write-Host "$([math]::Round($fileInfo.Length / 1MB,2)) MB"
Write-Host "Chunk size:"
Write-Host "$ChunkSizeMB MB"
Write-Host ""


# Open source file
$stream = [System.IO.File]::OpenRead($inputPath)


$buffer = New-Object byte[] $chunkSize

$chunkNumber = 0


while (($bytesRead = $stream.Read($buffer, 0, $buffer.Length)) -gt 0) {


    # Creates names:
    # model_chunk_0000.bin
    # model_chunk_0001.bin
    # model_chunk_0002.bin

    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($InputFile)

    $extension = [System.IO.Path]::GetExtension($InputFile)


    $outputFile = Join-Path `
        $outputFolder `
        ("{0}_chunk_{1:D4}{2}" -f `
        $baseName, `
        $chunkNumber, `
        $extension)


    # Write chunk
    [System.IO.File]::WriteAllBytes(
        $outputFile,
        $buffer[0..($bytesRead-1)]
    )


    Write-Host "Created:"
    Write-Host $outputFile


    $chunkNumber++
}


$stream.Close()


Write-Host ""
Write-Host "Finished!"
Write-Host "Created $chunkNumber chunks."
Write-Host "Chunks are located in:"
Write-Host $outputFolder