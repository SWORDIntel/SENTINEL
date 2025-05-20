[![GitHub Committed](https://img.shields.io/github/last-commit/jokob-sk/mount-bookmark?color=40ba12&label=Pushed&logo=GitHub&logoColor=fff&style=for-the-badge)](https://github.com/jokob-sk/NetAlertX)
[![Docker Size](https://img.shields.io/docker/image-size/jokobsk/mount-bookmark?label=Size&logo=Docker&color=0aa8d2&logoColor=fff&style=for-the-badge)](https://hub.docker.com/r/jokobsk/netalertx)
[![Docker Pulls](https://img.shields.io/docker/pulls/jokobsk/mount-bookmark?label=Pulls&logo=docker&color=0aa8d2&logoColor=fff&style=for-the-badge)](https://hub.docker.com/r/jokobsk/netalertx)

# Mount Bookmark :mount_fuji:

![image](https://i.imgur.com/NWen5UX.png)

Based on https://github.com/LinoIten/mount-bookmark.
Source code: On [GitHub](https://github.com/jokob-sk/mount-bookmark)

Mount Bookmark is a self-hosted, highly customizable bookmark board that allows you to view YouTube stream/videos, images, gif in the background.

# Installation :volcano:

First clone the sourcecode:

```cmd
git clone https://github.com/LinoIten/mount-bookmark.git
```

To run the react project:

```cmd
npm start
```

If you want to run it in the background you can use [PM2](https://pm2.keymetrics.io/).
```cmd
npm install pm2@latest -g
pm2 start --name mount-bookmark npm -- start
```

For having it as a "New Tab" page you could use the [New Tab Redirect Extension](https://chrome.google.com/webstore/detail/new-tab-redirect/icpgjfneehieebagbmdbhnlpiopdcmna) for Chrome. 

# Customization:scroll:

Under **/src/config** you'll find two json files. 

### colorPalette.json

```json
{
  "backroundBox": "rgba(37,42,51,0.98)",
  "icon": "rgba(252,252,252,1.0)",
  "accent1": "rgba(242,183,86,1.0)",
  "text": {
    "primary": "#FCFCFC",
    "secondary": "rgba(242,183,86,0.5)"
  }
}
```

As the name suggests here you can define all the colors in the app. You can use both **HEX** and **rgba()**.

### settings.json

```json
{    
    "imageSettings": {
        "images":[
            {
                "name":"Waterfall at night",
                "url":"https://wallpapercave.com/wp/wp1933958.jpg"
            },
            {
                "name":"Astronaut",
                "url":"https://lh5.googleusercontent.com/proxy/1CsxqsY1hHL5v39__UEhFi9GApkgS4FEj6iifuI8dDyBLz-quDnIQ7_1hYkCii8TEdn9w433xmmnBCkIENQCzzr7du0tsbFgj7qNSHU=w1200-h630-p-k-no-nu"                
            }
        ]
    },
    "videoSettings": {
        "videoId": "ecNdpdUlhFg",         
        "videoIds": [
            { 
                "name":"Reef",         
                "id" : "F109TZt3nRc"
            },            
            { 
                "name":"Rain",         
                "id" : "NT_BJr1GAHY"
            },
            { 
                "name":"Stormy weather",         
                "id" : "ZYtdU5Taie4"
            }
        ],
        "autoplay": true,
        "mute": 1,        
        "offSet": {
            "top": "0px",
            "right": "0px",
            "bottom": "0px",
            "left": "0px"
        }
    },
    "generalSettings":{
        "infoIcon": "M11,9H13V7H11M12,20C7.59,20 4,16.41 4,12C4,7.59 7.59,4 12,4C16.41,4 20,7.59 20,12C20,16.41 16.41,20 12,20M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M11,17H13V11H11V17Z",
        "refreshBackgroundSeconds": 300        
    },
    "searchSettings": {
        "keepDefaultIcon": true,
        "defaultSearchEngine":            
        {
            "key":"",
            "name":"",
            "url":"https://www.duckduckgo.com/?q=",
            "iconSVGPath":"M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z"
        },  
        "searchEngines":[
            {
                "key":"e",
                "name":"Ecosia",
                "url":"https://www.ecosia.org/search?q=",
                "iconSVGPath":"M17.9,17.39C17.64,16.59 16.89,16 16,16H15V13A1,1 0 0,0 14,12H8V10H10A1,1 0 0,0 11,9V7H13A2,2 0 0,0 15,5V4.59C17.93,5.77 20,8.64 20,12C20,14.08 19.2,15.97 17.9,17.39M11,19.93C7.05,19.44 4,16.08 4,12C4,11.38 4.08,10.78 4.21,10.21L9,15V16A2,2 0 0,0 11,18M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2"
            },
            {
                "key":"g",
                "name":"Google",
                "url":"https://www.google.com/search?q=",
                "iconSVGPath":"M21.35,11.1H12.18V13.83H18.69C18.36,17.64 15.19,19.27 12.19,19.27C8.36,19.27 5,16.25 5,12C5,7.9 8.2,4.73 12.2,4.73C15.29,4.73 17.1,6.7 17.1,6.7L19,4.72C19,4.72 16.56,2 12.1,2C6.42,2 2.03,6.8 2.03,12C2.03,17.05 6.16,22 12.25,22C17.6,22 21.5,18.33 21.5,12.91C21.5,11.76 21.35,11.1 21.35,11.1V11.1"
            },
            {
                "key":"d",
                "name":"Duckduckgo",
                "url":"https://www.duckduckgo.com/?q=",
                "iconSVGPath":"M8.5,5A1.5,1.5 0 0,0 7,6.5A1.5,1.5 0 0,0 8.5,8A1.5,1.5 0 0,0 10,6.5A1.5,1.5 0 0,0 8.5,5M10,2A5,5 0 0,1 15,7C15,8.7 14.15,10.2 12.86,11.1C14.44,11.25 16.22,11.61 18,12.5C21,14 22,12 22,12C22,12 21,21 15,21H9C9,21 4,21 4,16C4,13 7,12 6,10C2,10 2,6.5 2,6.5C3,7 4.24,7 5,6.65C5.19,4.05 7.36,2 10,2Z"
            },
            {
                "key":"b",
                "name":"Bing",
                "url":"https://www.bing.com/search?q=",
                "iconSVGPath":"M5,3V19L8.72,21L18,15.82V11.73H18L9.77,8.95L11.38,12.84L13.94,14L8.7,16.92V4.27L5,3"
            },
            {
                "key":"m",
                "name":"Maps",
                "url":"https://www.google.com/maps/search/",
                "iconSVGPath":"M18.27 6C19.28 8.17 19.05 10.73 17.94 12.81C17 14.5 15.65 15.93 14.5 17.5C14 18.2 13.5 18.95 13.13 19.76C13 20.03 12.91 20.31 12.81 20.59C12.71 20.87 12.62 21.15 12.53 21.43C12.44 21.69 12.33 22 12 22H12C11.61 22 11.5 21.56 11.42 21.26C11.18 20.53 10.94 19.83 10.57 19.16C10.15 18.37 9.62 17.64 9.08 16.93L18.27 6M9.12 8.42L5.82 12.34C6.43 13.63 7.34 14.73 8.21 15.83C8.42 16.08 8.63 16.34 8.83 16.61L13 11.67L12.96 11.68C11.5 12.18 9.88 11.44 9.3 10C9.22 9.83 9.16 9.63 9.12 9.43C9.07 9.06 9.06 8.79 9.12 8.43L9.12 8.42M6.58 4.62L6.57 4.63C4.95 6.68 4.67 9.53 5.64 11.94L9.63 7.2L9.58 7.15L6.58 4.62M14.22 2.36L11 6.17L11.04 6.16C12.38 5.7 13.88 6.28 14.56 7.5C14.71 7.78 14.83 8.08 14.87 8.38C14.93 8.76 14.95 9.03 14.88 9.4L14.88 9.41L18.08 5.61C17.24 4.09 15.87 2.93 14.23 2.37L14.22 2.36M9.89 6.89L13.8 2.24L13.76 2.23C13.18 2.08 12.59 2 12 2C10.03 2 8.17 2.85 6.85 4.31L6.83 4.32L9.89 6.89Z"
            },
            {
                "key":"y",
                "name":"YouTube",
                "url":"https://www.youtube.com/results?search_query=",
                "iconSVGPath":"M10,15L15.19,12L10,9V15M21.56,7.17C21.69,7.64 21.78,8.27 21.84,9.07C21.91,9.87 21.94,10.56 21.94,11.16L22,12C22,14.19 21.84,15.8 21.56,16.83C21.31,17.73 20.73,18.31 19.83,18.56C19.36,18.69 18.5,18.78 17.18,18.84C15.88,18.91 14.69,18.94 13.59,18.94L12,19C7.81,19 5.2,18.84 4.17,18.56C3.27,18.31 2.69,17.73 2.44,16.83C2.31,16.36 2.22,15.73 2.16,14.93C2.09,14.13 2.06,13.44 2.06,12.84L2,12C2,9.81 2.16,8.2 2.44,7.17C2.69,6.27 3.27,5.69 4.17,5.44C4.64,5.31 5.5,5.22 6.82,5.16C8.12,5.09 9.31,5.06 10.41,5.06L12,5C16.19,5 18.8,5.16 19.83,5.44C20.73,5.69 21.31,6.27 21.56,7.17Z"
            }
        ],
        "styles":{            
            "minScreenWidthToEnableHide":"780px",
            "hideAnimationDelaySeconds":"3",
            "hideAnimationDurationSeconds":"2",
            "opacityAtAnimationStart":"0.8",
            "opacityAtAnimationEnd":"0.2"      
        }
    },
    "bookmarksShowIconInPopup":true,
    "bookmarks":[
      {
        "category":"Video", 
        "name":"YouTube",
        "url":"https://www.youtube.com/",
        "iconSVGPath":"M10,15L15.19,12L10,9V15M21.56,7.17C21.69,7.64 21.78,8.27 21.84,9.07C21.91,9.87 21.94,10.56 21.94,11.16L22,12C22,14.19 21.84,15.8 21.56,16.83C21.31,17.73 20.73,18.31 19.83,18.56C19.36,18.69 18.5,18.78 17.18,18.84C15.88,18.91 14.69,18.94 13.59,18.94L12,19C7.81,19 5.2,18.84 4.17,18.56C3.27,18.31 2.69,17.73 2.44,16.83C2.31,16.36 2.22,15.73 2.16,14.93C2.09,14.13 2.06,13.44 2.06,12.84L2,12C2,9.81 2.16,8.2 2.44,7.17C2.69,6.27 3.27,5.69 4.17,5.44C4.64,5.31 5.5,5.22 6.82,5.16C8.12,5.09 9.31,5.06 10.41,5.06L12,5C16.19,5 18.8,5.16 19.83,5.44C20.73,5.69 21.31,6.27 21.56,7.17Z"
      },
      {
        "category":"Notes",         
        "name":"Google Keep",
        "url":"https://keep.google.com/",
        "iconSVGPath":""
      },
      {
        "category":"Entertainment",         
        "name":"Reddit",
        "url":"https://www.reddit.com/",
        "iconSVGPath":"M22 12.14a2.19 2.19 0 0 0-3.71-1.57 10.93 10.93 0 0 0-5.86-1.87l1-4.7 3.27.71a1.56 1.56 0 1 0 .16-.76l-3.64-.77c-.11-.02-.22 0-.29.06-.09.05-.14.14-.16.26l-1.11 5.22c-2.33.07-4.43.78-5.95 1.86A2.2 2.2 0 0 0 4.19 10a2.16 2.16 0 0 0-.9 4.15 3.6 3.6 0 0 0-.05.66c0 3.37 3.92 6.12 8.76 6.12s8.76-2.73 8.76-6.12c0-.21-.01-.44-.05-.66A2.21 2.21 0 0 0 22 12.14M7 13.7c0-.86.68-1.56 1.54-1.56s1.56.7 1.56 1.56a1.56 1.56 0 0 1-1.56 1.56c-.86.02-1.54-.7-1.54-1.56m8.71 4.14C14.63 18.92 12.59 19 12 19c-.61 0-2.65-.1-3.71-1.16a.4.4 0 0 1 0-.57.4.4 0 0 1 .57 0c.68.68 2.14.91 3.14.91s2.47-.23 3.14-.91a.4.4 0 0 1 .57 0c.14.16.14.41 0 .57m-.29-2.56c-.86 0-1.56-.7-1.56-1.56a1.56 1.56 0 0 1 1.56-1.56c.86 0 1.58.7 1.58 1.56a1.6 1.6 0 0 1-1.58 1.56z"
      },
      {
        "category":"Hacking",         
        "name":"GitHub",
        "url":"https://github.com/",
        "iconSVGPath":""
      }
      
    ],
     "labelStyles" : 
    {
      "color":"white",
      "backgroundColor":"black",
      "opacity":"0.9"
    },
    "searchBoxContainerStyles":
    {
      "alignContent":"center",
      "display": "flex",
      "justifyContent": "center",
      "backgroundColor":"transparent"
    },
    "searchBoxStyles":
    {      
      "borderRadius": "10px",
      "padding": "20px",
      "backgroundColor":"rgba(37,42,51,0.98)",
      "width":"300px",
      "opacity":"0.9"
    },
    "searchInputStyles":
    {      
      "color": "white !important", 
      "underlineColor": "grey" 
    },
    "searchIconStyles":
    {      
      "color": "white"      
    },
    "paperStyles": {     
      "color":"white",
      "backgroundColor":"black",
      "size":"smaller",
      "hoverColor": "rgba(37,42,51,0.98)"
   }
}

```

> **_Note:_**  Currently the only way to use Icons is to use the svg-path

Get them here: https://materialdesignicons.com/

The names of each attribute should be fairly self-explanatory.

If you want to override the search engine specified in the `settings.json` file use the following characters + a space:

- 'e' for https://www.ecosia.org/
- 'd' for https://www.duckduckgo.com/
- 'g' for https://www.google.com/
- 'b' for https://www.bing.com/
- 'm' for https://www.google.com/maps/

So for example if you want to use duckduckgo.com to search for the term 'mount bookmark' type `d mount bookmark`

You can modify these in the `settings.json` file. 

# Local artwork:scroll:

Local artwork can be placed in a src/config/local_artwork/<subfolder> folder. Use folder names without spaces for best results. 
  
# Docker
    
- Map your settings.json to ```/opt/src/config/settings.json```
- Map your background images location to ```/opt/src/config/local_artwork/``` (⚠ Images with spaces in names might cause issues)
- Map your port to `:3000`
  
  <a href="https://www.buymeacoffee.com/jokobsk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 30px !important;width: 117px !important;" width="117" height="30"></a>
