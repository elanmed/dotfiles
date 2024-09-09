source "$HOME/.dotfiles/duplicity/.duplicity/.env"

LOG_FILE="$HOME/.dotfiles/duplicity/.duplicity/info.log"
echo "" > $LOG_FILE

# TODO: update dir

duplicity \
    --full-if-older-than "7D" \
    --log-file "$LOG_FILE" \
    "$HOME/Desktop/test-dir/" \
    "boto3+s3://macbook-pro-2020/"

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset PASSPHRASE
