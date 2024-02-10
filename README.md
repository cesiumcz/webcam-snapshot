# cesium webcam snapshot
Shell script-based routine that takes unique snapshots from live JPEG images published on the Web.

## Prerequisities
- Shell - `bash` or Korn shell `ksh` (OpenBSD's default shell)
- `curl`

## Installation
### System user

	useradd -c "Webcam routine" -b /var/webcam/ -d /var/webcam-snapshot/ -s /sbin/nologin _webcam
	install -d -m 770 -o root -g _webcam /var/webcam-snapshot/

### Clone & file copy

	cd /tmp/
	git clone https://github.com/cesiumcz/webcam-snapshot.git

Determine correct version `bash`/`ksh`:

	mv snap.(bash|ksh) snap.sh

Install the script and set correct permissions

	install -d -m 755 -o root -g _webcam /usr/local/webcam-snapshot/
	install -m 754 -o root -g _webcam snap.sh /usr/local/webcam-snapshot/
	rm -rf /tmp/webcam-snapshot/

### Configuration
#### Camera list

	vim /usr/local/webcam-snapshot/cameras.txt

For each webcam, insert a line according to the following syntax:

	cam_name jpg_uri

- *cam_name* = unique string camera name. Use short and simple names.
- *jpg_uri* = URI to JPEG image

A line starting with `#` is ignored.

Example contents of `cameras.txt`

	pec https://www.chmi.cz/files/portal/docs/meteo/kam/pecpodsnezkou.jpg
	jizerka https://www.chmi.cz/files/portal/docs/meteo/kam/jizerka.jpg

Set proper permissions (`cameras.txt` is likely to contain credentials)

	chown -R root:_webcam /usr/local/webcam-snapshot/
	chmod 660 /usr/local/webcam-snapshot/cameras.txt

### Cron
Invoke the script every minute between 6 to 18 hours:

	crontab -e -u _webcam
	* 6-18 * * * /usr/local/webcam-snapshot/snap.sh

## Testing

	su -l _webcam /usr/local/webcam-snapshot/snap.sh

Or alternative using `doas` command:

	doas -u _webcam /usr/local/webcam-snapshot/snap.sh

## Modus operandi
**`snap.sh`** does the following sequentially for each webcam:
- downloads current image into temporary location, if succeeds:
- checks if the new image differs from the last downloaded, if so:
- moves the second oldest image into final location

### Directory structure
	/tmp/webcam-snapshot/
	|-- cam1
	|   `-- 202401201023.jpg
	`-- cam2
	    `-- 202401201023.jpg

	/var/webcam-snapshot/
	|-- cam1
	|   |-- 202401201020.jpg
	|   `-- 202401201010.jpg
	`-- cam2
	    |-- 202401201020.jpg
	    `-- 202401201010.jpg

## Author
[Matyáš Vohralík](https://mv.cesium.cz), 2024

## License
[BSD 3-Clause](LICENSE)
