param(
    [int]$Port = 3002
)

$root = $PSScriptRoot
if (-not $root) {
    $root = "w:\CUSTOM METAL WORK\Website\teachers-day-faisal-noor"
}

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")

$mimeTypes = @{
    ".html"  = "text/html; charset=utf-8"
    ".htm"   = "text/html; charset=utf-8"
    ".css"   = "text/css; charset=utf-8"
    ".js"    = "application/javascript; charset=utf-8"
    ".json"  = "application/json; charset=utf-8"
    ".png"   = "image/png"
    ".jpg"   = "image/jpeg"
    ".jpeg"  = "image/jpeg"
    ".gif"   = "image/gif"
    ".svg"   = "image/svg+xml"
    ".ico"   = "image/x-icon"
    ".mp4"   = "video/mp4"
    ".webm"  = "video/webm"
    ".woff"  = "font/woff"
    ".woff2" = "font/woff2"
    ".ttf"   = "font/ttf"
}

try {
    $listener.Start()
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host " Dr. Mohammad Faisal Noor -- Teacher's Day Tribute Portal" -ForegroundColor Yellow
    Write-Host " LM Thapar School of Management (LMTSM)" -ForegroundColor Yellow
    Write-Host "===============================================================" -ForegroundColor Cyan
    Write-Host " Server Running at: http://localhost:$Port/" -ForegroundColor Green
    Write-Host " Resilient Video Streaming (HTTP 206) Enabled." -ForegroundColor Green
    Write-Host " Press Ctrl+C to stop." -ForegroundColor Gray
    Write-Host "===============================================================" -ForegroundColor Cyan

    while ($listener.IsListening) {
        $context = $listener.GetContext()

        # Handle each request in a protected block so client disconnects never crash the server
        try {
            $request = $context.Request
            $response = $context.Response

            $rawUrl = $request.RawUrl
            $urlPart = $rawUrl.Split('?')[0]
            if ($urlPart -eq "/" -or $urlPart -eq "") {
                $urlPart = "/index.html"
            }

            $decodedPath = [System.Uri]::UnescapeDataString($urlPart).TrimStart('/')
            $localPath = Join-Path $root $decodedPath

            if (Test-Path $localPath -PathType Leaf) {
                $ext = [System.IO.Path]::GetExtension($localPath).ToLower()
                $contentType = "application/octet-stream"
                if ($mimeTypes.ContainsKey($ext)) {
                    $contentType = $mimeTypes[$ext]
                }

                $response.ContentType = $contentType
                $response.AddHeader("Accept-Ranges", "bytes")

                $fileInfo = New-Object System.IO.FileInfo($localPath)
                $fileLength = $fileInfo.Length

                $rangeHeader = $request.Headers["Range"]
                if ($rangeHeader -and $rangeHeader.StartsWith("bytes=")) {
                    $rangeClean = $rangeHeader.Substring(6)
                    $hyphenIndex = $rangeClean.IndexOf("-")
                    $startStr = $rangeClean.Substring(0, $hyphenIndex)
                    $endStr = $rangeClean.Substring($hyphenIndex + 1)

                    $start = [int64]$startStr
                    $end = $fileLength - 1
                    if ($endStr -ne "") {
                        $end = [int64]$endStr
                    }
                    if ($end -ge $fileLength) {
                        $end = $fileLength - 1
                    }
                    $contentLength = $end - $start + 1

                    $response.StatusCode = 206
                    $response.AddHeader("Content-Range", "bytes $start-$end/$fileLength")
                    $response.ContentLength64 = $contentLength

                    $fs = [System.IO.File]::OpenRead($localPath)
                    try {
                        $null = $fs.Seek($start, [System.IO.SeekOrigin]::Begin)
                        $buffer = New-Object byte[] (64 * 1024)
                        $bytesRemaining = $contentLength
                        while ($bytesRemaining -gt 0) {
                            $bytesToRead = [Math]::Min($buffer.Length, $bytesRemaining)
                            $bytesRead = $fs.Read($buffer, 0, $bytesToRead)
                            if ($bytesRead -le 0) { break }
                            $response.OutputStream.Write($buffer, 0, $bytesRead)
                            $bytesRemaining -= $bytesRead
                        }
                    } finally {
                        $fs.Close()
                    }
                } else {
                    $response.StatusCode = 200
                    $response.ContentLength64 = $fileLength
                    $fs = [System.IO.File]::OpenRead($localPath)
                    try {
                        $fs.CopyTo($response.OutputStream)
                    } finally {
                        $fs.Close()
                    }
                }
            } else {
                $response.StatusCode = 404
                $buffer = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
                $response.ContentLength64 = $buffer.Length
                $response.OutputStream.Write($buffer, 0, $buffer.Length)
            }
        } catch {
            # Catch broken pipe or closed stream when user skips video
        } finally {
            try { $response.OutputStream.Close() } catch {}
            try { $response.Close() } catch {}
        }
    }
} catch {
    Write-Host "Server Error: $_" -ForegroundColor Red
} finally {
    if ($listener.IsListening) {
        $listener.Stop()
    }
    $listener.Close()
}
