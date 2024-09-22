source ~/.dotfiles/duplicity/.duplicity/.env
source ~/.dotfiles/helpers.sh

LOG_FILE="$HOME/.dotfiles/duplicity/.duplicity/info.log"
echo "" > $LOG_FILE

REMOVE_START=`date +%s`
duplicity remove-older-than "2M" "$DUPLICITY_DEST" --force --log-file "$LOG_FILE"
REMOVE_END=`date +%s`
REMOVE_RUNTIME=$((REMOVE_END-REMOVE_START))
h_cecho --noop "remove took $REMOVE_RUNTIME seconds"

BACKUP_START=`date +%s`
duplicity --full-if-older-than "7D" "$DUPLICITY_SOURCE" "$DUPLICITY_DEST" --log-file "$LOG_FILE" 
BACKUP_END=`date +%s`
BACKUP_RUNTIME=$((BACKUP_END-BACKUP_START))
h_cecho --noop "backup took $BACKUP_RUNTIME seconds"

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset PASSPHRASE
unset DUPLICITY_SOURCE
unset DUPLICITY_DEST
