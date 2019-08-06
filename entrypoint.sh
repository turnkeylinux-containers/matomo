MY=(
    [ROLE]=app
    [RUN_AS]=www

    [APP_NAME]="${APP_NAME:-TurnKey Matomo}"
    [APP_USER]="${APP_USER:-admin}"
    [APP_MAIL]="${APP_MAIL:-admin@example.com}"
    [APP_PASS]="${APP_PASS:-}"
    [APP_SITE]="${APP_SITE:-}" # unused for now

    [DB_HOST]="${DB_HOST:-127.0.0.1}"
    [DB_USER]="${DB_USER:-matomo}"
    [DB_NAME]="${DB_NAME:-matomo}"
    [DB_PASS]="${DB_PASS:-$(secret consume DB_PASS)}"
    [DB_PREFIX]="${DB_PREFIX:-matomo_}"
)

passthrough_unless 'php-fpm' "$@"

INITDB="${OUR[INITDBS]}/matomo.sql"
add vhosts matomo
web_extract_src matomo 

SQL="${OUR[SRCDIR]}/matomo-3.11.0.sql"

cp "${OUR[SRCDIR]}/config.ini.php" "${OUR[WEBDIR]}/config"

sed -i "s|host = \".*\"|host = \"${MY[DB_HOST]}\"|" "${OUR[WEBDIR]}/config/config.ini.php"

sed -i "s|username = \".*\"|username = \"${MY[DB_USER]}\"|" "${OUR[WEBDIR]}/config/config.ini.php"

sed -i "s|password = \".*\"|password = \"${MY[DB_PASS]}\"|" "${OUR[WEBDIR]}/config/config.ini.php"

sed -i "s|dbname = \".*\"|dbname = \"${MY[DB_NAME]}\"|" "${OUR[WEBDIR]}/config/config.ini.php"

sed -i "s|salt = \".*\"|salt = \"$(mcookie)\"|" "${OUR[WEBDIR]}/config/config.ini.php"


sed -i "s|#__|${MY[DB_PREFIX]}|" "${SQL}"

cp "${SQL}" "${INITDB}"
unset SQL

PASS_HASH="$(php -r "echo password_hash(md5('${APP_PASS}'), PASSWORD_DEFAULT);")"

# add trusted host
echo "UPDATE matomo_option SET option_value='${APP_HOST}' WHERE option_name='matomoUrl';" >> "${INITDB}"
sed -i "s|trusted_hosts\[\] = \".*\"|trusted hosts\[\] = \"${APP_HOST}\"|" "${OUR[WEBDIR]}/config/config.ini.php"

# update admin user
echo "UPDATE matomo_user SET email='${APP_MAIL}';" >> "${INITDB}"
echo "UPDATE matomo_user SET password='${PASS_HASH}'" >> "${INITDB}"


random_if_empty APP_PASS


chown -R www-data:www-data "${OUR[WEBDIR]}"


#reload_vhosts
run "$@"
