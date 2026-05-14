# Karoo GPX bulk exporter

This PowerShell script uses your temporary access token to call the unofficial Hammerhead API to download all routes at once as GPX so you don't have to manually download each one.

## Usage
1. Download the script (`gpx-exporter.ps1`) from the source code.
2. Optain your API token (valid for 1h). Go to dashboard.hammerhead.io -> Login -> Open Chrome Developer Menu (F12) -> Network -> Filter for Fetch/XHR -> Look for a request like `profile` or `feature` and click it. Select `headers` and look for `Authorization`. Now you see `Bearer YOUR_TOKEN`. Copy your token without the bearer part.

<img width="1880" height="653" alt="image" src="https://github.com/user-attachments/assets/ae01e966-296a-43d2-9e77-79d7735bbdf6" />

3. Optain your UserId. Again in the Developer tools under Network look for a request to `profile`. Click it and go to the `Response` tab. There you see your id. Only copy the numbers.

<img width="722" height="342" alt="image" src="https://github.com/user-attachments/assets/dc652e50-8d78-40ac-bc31-3b73a3a0719c" />
 
3. Open the terminal at the location you saved the script.
4. Run the script in the terminal:
```
$env:KAROO_TOKEN = "YOUR_TOKEN"
$env:KAROO_USER_ID = "12345" 
./gpx-exporter.ps1
```
