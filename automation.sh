# deck_startup.webm file names/locations
NOW=$(date +"%Y-%m-%d-%H-%M-%S")
webm_loc="/home/deck/.local/share/Steam/steamui/movies/"
deck_startup_loc=$webm_loc"deck_startup.webm"
deck_startup_backup_loc=$webm_loc"BACKUP_deck_startup.$NOW.webm"
# CSS file names/locations/strings
css_loc="/home/deck/.local/share/Steam/steamui/css/library.css"
old_css="video{flex-grow:0;width:300px;height:300px;z-index:10}"
new_css="video{flex-grow:1;width:100%;height:100%;z-index:10}"

check_ret_code () {
    retVal=$?
    if [ $retVal -ne 0 ]; then
        echo "Error Code $?. Exiting script."
        exit $retVal
    fi
}

backup_original_deck_webm () {
    echo "Making backup of deck_startup.webm"
    cp $deck_startup_loc $deck_startup_backup_loc &> /dev/null
    check_ret_code
}

download_new_startup_webm () {
    # Install pip and gdown, download webm, replace current file with new
    echo "Installing pip through ensurepip"
    python3 -m ensurepip --default-pip &> /dev/null
    check_ret_code
    echo "Upgrading pip, setuptools, and wheel"
    python3 -m pip install --upgrade pip setuptools wheel &> /dev/null
    check_ret_code
    echo "Installing gdown for downloading files from google drive"
    python3 -m pip install gdown &> /dev/null
    check_ret_code
    echo "Running self contained python script to download new deck_startup.webm from google drive. ID passed: $1"
    python3 -c "import gdown; gdown.download(id='$1', output='deck_startup.webm', quiet=False)"
    check_ret_code
}

move_new_file_to_directory() {
    echo "Moving downloaded file to movies folder"
    mv deck_startup.webm $deck_startup_loc &> /dev/null
    check_ret_code
}

update_css () {
    # Update the css file
    echo "Replacing old css with new css"
    sed -i "s/$old_css/$new_css/" $css_loc &> /dev/null
    check_ret_code
    echo "Truncating library css file"
    truncate -s 38492 $css_loc &> /dev/null
}

main () {
    backup_original_deck_webm
    download_new_startup_webm $1
    move_new_file_to_directory
    update_css
}

if [ $# -eq 1 ]
  then
    echo "$# argument supplied with '$1'"
    main $1
else
    echo "$# arguments given. Expecting 1."
fi
