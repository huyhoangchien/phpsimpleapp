# php_simple_app

Version 2 - What's new - Actually, it's the 4 points in the email:

1. The provisioning of server was completed, but web page could not be opened.
I examined virtual machine and found the following:
Mar 22 16:30:31 localhost nohup: [Thu Mar 22 16:30:31 2018] PHP Fatal error:  Class 'PDO' not found in /var/app/simplephpapp/vendor/laravel/framework/src/Illuminate/Database/Connection.php on line 1200
Mar 22 16:30:38 localhost nohup: [Thu Mar 22 16:30:38 2018] PHP Fatal error:  Class 'PDO' not found in /var/app/simplephpapp/vendor/laravel/framework/src/Illuminate/Database/Connection.php on line 1200
These error messages mean that RPM package php-pdo was not installed.

=> Already added in this version

2.  fulfilling the installation of required package I found that stage of generating static files was not completed successfully.
Several NodeJS packages must be installed manually and NPM shows warning message about that.
https://jing.saritasa.com/AlekseyZolotuhin/Screenshot_at_2018-03-22-58-13.png

=> There were something wrong with npm while I was trying to install the package json file, so, I decided to yarn instead of npm.

3. The candidate decided to use PHP built-in web server.
This is not a failure, but decision leads to incorrect displaying of application because it does not allow to serve static files by web server itself.
As a result the application looks different in comparison with the screenshot provided in Git repository.
https://jing.saritasa.com/AlekseyZolotuhin/Screenshot_at_2018-03-22-41-30.png

=> Using apache to run the app

4. And the next point is about reading documentation and using the obtained info from it.
He uses 'execute' directive for installing RPM packages using YUM package manager.
This leads to error if we launch recipe repeatedly because there should be used 'package' directive that processes the installation of packages properly.

=> I have moved it to chef rpm package 
