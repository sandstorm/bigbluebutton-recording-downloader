#!/bin/sh

set -e

rm -rf tmp

show_help()
{
echo "
        Usage: Download BBB Recordings [-u Url] [-m Meeting Id] [-d] [-w] [-o [topright|bottomright|topleft|bottomleft]]

        -u Url             BBB Url, e.g. https://bbb.example.org
        -m Meeting Id      Internal Meeting ID - Can found in the url when watching a recording.
        -d                 Create a video with audio of the deskshare.
        -w                 Create a video with audio of the webcamsfeed.
        -o Position        Create a video with audio of the deskshare with a webcam overlay.
"
}

while getopts Hu:m:dwo: option
do
  case "${option}"
  in
  d) deskshare=true;;
  o) overlay=${OPTARG};;
  m) meetingId=${OPTARG};;
  u) url=${OPTARG};;
  w) webcams=true;;
  H) show_help;;
 esac
done

echo $meetingId

[[ -z "$url" ]] && echo "No url provided" && exit 0
[[ -z "$meetingId" ]] && echo "No meeting ID provided" && exit 0

case "$overlay" in
  topleft)
    ffmpegOverlay="";;
  topright)
    ffmpegOverlay="overlay=main_w-(overlay_w)";;
  bottomleft)
    ffmpegOverlay="overlay=main_h-(overlay_h)";;
  bottomright)
    ffmpegOverlay="overlay=main_w-(overlay_w):main_h-(overlay_h)";;
esac

# create a tmp folder
rm -rf tmp
mkdir -p tmp
cd tmp

# download
curl $url/presentation/$meetingId/deskshare/deskshare.webm --output deskshare.webm
curl $url/presentation/$meetingId/video/webcams.webm --output webcams.webm
curl $url/presentation/$meetingId/metadata.xml --output metadata.xml

timestamp=$(grep -e '<start_time>.*</start_time>' metadata.xml)
timestamp=${timestamp/<start_time>}
timestamp=${timestamp/<\/start_time>}
timestamp=$((timestamp/1000))

dateString=$(date -r "$timestamp" +'%Y-%m-%d')

meetingName=$(grep -e '<meetingName>.*</meetingName>' metadata.xml)
meetingName=${meetingName/<meetingName>}
meetingName=${meetingName/<\/meetingName>}
meetingName=${meetingName//[^[:alnum:]]/}

mkdir -p ../downloads
mkdir -p ../downloads/"$meetingName"

outputPathAndNamePrefix=../downloads/"$meetingName"/"$meetingName"_"$dateString"

# add webcam sound to deskshare
ffmpeg -i webcams.webm -i deskshare.webm -c copy deskshare_with_sound.webm

rm -f "$outputPathAndNamePrefix"_deskshare.mp4
rm -f "$outputPathAndNamePrefix"_webcams.mp4
rm -f "$outputPathAndNamePrefix"_deskshare_with_webcams.mp4

if [ "$deskshare" ]
  then
    ffmpeg -i deskshare_with_sound.webm "$outputPathAndNamePrefix"_deskshare.mp4
fi

if [ "$webcams" ]
  then
    ffmpeg -i webcams.webm "$outputPathAndNamePrefix"_webcams.mp4
fi

if [ "$ffmpegOverlay" ]
  then
    ffmpeg -i deskshare_with_sound.webm -vf "movie=webcams.webm,scale=250:-1[inner]; [in][inner] $ffmpegOverlay [out]" "$outputPathAndNamePrefix"_deskshare_with_webcams.mp4
fi

cd ..
rm -rf tmp
