#!/bin/bash
# compress_video.sh - 压缩视频为 GitHub Pages 友好格式
# 用法: ./compress_video.sh input.mp4 output.mp4 [分辨率] [码率]
# 示例: ./compress_video.sh front_long.mp4 front_long_compressed.mp4 720p 3M

INPUT="$1"
OUTPUT="$2"
RESOLUTION="${3:-720p}"
BITRATE="${4:-3M}"

if [ -z "$INPUT" ] || [ -z "$OUTPUT" ]; then
    echo "用法: $0 <输入文件> <输出文件> [分辨率] [码率]"
    echo "示例: $0 front_long.mp4 front_long_compressed.mp4 720p 3M"
    echo ""
    echo "分辨率选项: 480p, 720p, 1080p"
    echo "码率选项: 2M, 3M, 5M, 8M"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "错误: ffmpeg 未安装"
    echo "安装方式:"
    echo "  macOS: brew install ffmpeg"
    echo "  Ubuntu/Debian: sudo apt install ffmpeg"
    echo "  Windows: winget install ffmpeg 或 https://ffmpeg.org/download.html"
    exit 1
fi

echo "开始压缩视频..."
echo "输入: $INPUT"
echo "输出: $OUTPUT"
echo "分辨率: $RESOLUTION"
echo "码率: $BITRATE"
echo ""

# 获取输入视频信息
echo "输入视频信息:"
ffprobe -v quiet -show_entries stream=width,height,duration -of csv=p=0 "$INPUT" | head -3
echo ""

# 压缩命令
ffmpeg -i "$INPUT" \
    -vf "scale=-2:${RESOLUTION}" \
    -c:v libx264 \
    -preset medium \
    -crf 23 \
    -maxrate "$BITRATE" \
    -bufsize "$(( ${BITRATE%M} * 2 ))M" \
    -c:a aac \
    -b:a 128k \
    -movflags +faststart \
    -y \
    "$OUTPUT"

echo ""
echo "压缩完成!"

# 显示输出文件大小
INPUT_SIZE=$(du -h "$INPUT" | cut -f1)
OUTPUT_SIZE=$(du -h "$OUTPUT" | cut -f1)
echo "原始大小: $INPUT_SIZE"
echo "压缩后: $OUTPUT_SIZE"
