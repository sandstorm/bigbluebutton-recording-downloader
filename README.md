# BigBlueButton - Recording Downloader

Currently downloads public recordings of BBB meetings and creates up to 3 video files for a given internal meeting id.

- `[Name of Meeting]_[Date]_deskshare.mp4`
- `[Name of Meeting]_[Date]_deskshare_with_webcams.mp4`
- `[Name of Meeting]_[Date]_webcams.mp4`

## How to install

`brew install ffmpeg`

## How to use

- run `./download.sh -H` for more help
- running the script will ...
    - this will create a `tmp` folder that will be removed when finished
    - this will create a `downloads` folder with subfolders for each meeting

## BBB Internal Meeting Id

Example: `abd12b32c0773cc53e5225171904c20f314e4179-1593714487545`

You can find it in the url when watching a recording in BBB or in the url that was send to you via E-Mail as an invitation to watch a recording in BBB ;)
