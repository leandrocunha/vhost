DOC_ROOT_PREFIX="/Users/[YOUR-USER]/[YOUR-PROJECTS-FOLDER]"
LOCALHOST='127.0.0.1'
EMAIL_ADMIN='user@localhost.com'

echo "Name of the project? "
read project_name

if [ "$project_name" ]; then

	echo "Setup project ${project_name}... "
	mkdir $DOC_ROOT_PREFIX/$project_name

	if [ -d $DOC_ROOT_PREFIX/$project_name ]; then
		PROJECT_FOLDER=$DOC_ROOT_PREFIX/$project_name
		PROJECT_LC=`php -r "print strtolower('$project_name');"`
		PROJECT_UC=`php -r "print strtoupper('$project_name');"`

		mkdir "$PROJECT_FOLDER/www"
		mkdir "$PROJECT_FOLDER/logs"		

		echo "Name of domain?"
		read domain_name

		/bin/echo "$LOCALHOST	dev.${domain_name}" >> /etc/hosts

		echo "Creating Vhost..."

		VHOST="
# $PROJECT_UC
<VirtualHost *:80>
    ServerAdmin $EMAIL_ADMIN
    DocumentRoot \"${DOC_ROOT_PREFIX}$project_name/www\"
    ServerName $domain_name
    ServerAlias dev.$domain_name
    ErrorLog \"${DOC_ROOT_PREFIX}$project_name/logs/error_log\"
    CustomLog \"${DOC_ROOT_PREFIX}$project_name/logs/access_log\" common

    <Directory \"${DOC_ROOT_PREFIX}$project_name/www\">
        Options Indexes FollowSymLinks
        Require all granted
        Order allow,deny
        Allow from all
    </Directory>
</VirtualHost>"

    	/bin/echo "$VHOST" >> /etc/apache2/extra/httpd-vhosts.conf

		read -r -p "Is a WordPress project? [Y/n] " response
		case $response in
		    [yY][eE][sS]|[yY]) 
		        echo "Cloning latest version of WordPress..."

		        cd $PROJECT_FOLDER && git clone git@github.com:WordPress/WordPress.git www/.
		        sudo rm -rf $PROJECT_FOLDER/www/.git
		        sudo httpd -k restart
		        /usr/bin/open -a "Google Chrome" "http://dev.$domain_name"
		        ;;
		    *)
		        echo "Bye"
		        ;;
		esac
	fi

else		
	echo "Project name is required!"
fi