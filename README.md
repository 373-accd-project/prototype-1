# ACCD BLS Query Application Technical Support Document



## 1) Download the Complete Repository from GitHub
### Before downloading any software follow the next steps to download the application onto your laptop locally.

Here: https://github.com/373-accd-project/prototype-1

On the right hand side there should be a green button that says 'Clone or download'. Click the button and choose 'Download ZIP'

Once the zip file is downloaded, make a folder in your Documents called 'bls-query-app'
Move the zip file inside and unzip the file, you may delete the zip file at this time if you prefer.

## 2) Download Ruby, Rails and Ubuntu
### The next steps are to download Ruby and Rails so that the application can run.

#### 1) Windows Subsystem for Linux (WSL)

Installation instructions are based on [these Windows docs](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

1) Enable the feature

    Open windows powershell as an administrator and enter:
    ```
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    ```

2) Restart your computer when prompted

3) Install Ubuntu 18.04 on WSL

    Find [Ubuntu 18.04 in the Windows store](https://www.microsoft.com/store/apps/9N9TNGVNDL3Q)
    and select "Get" on the distro page. Then select "Install".

4) Initialize your Ubuntu installation

    1) Launch Ubuntu 18.04 (it will take a minute to open)
    2) When prompted, enter a username of your choice
    3) When prompted, enter a password of your choice
    4) Record the credentials for the account you just created somewhere
    that you will not lose them
    5) Make sure you are running the most recent software (and will use
    it in the future)

    Enter this in the bash shell:
    ```
    sudo apt update && sudo apt upgrade
    ```
    Running this will take a while. You may be prompted about restarting
    services (such as ssh), this is fine.

5) Nice work

    1) Entering `ls` will list everything in the working directory. Right
    now you will probably see nothing.
    2) `pwd` will print the working directory (where you are right now)
    3) Entering `cd [some path]` will change the current directory to the
    given path.
    4) *Important:* you can get to your windows files (and you will likely
    want to do this for the rest of this class)

        ```
        cd /mnt/
        ```
        or, you can probably get all the way to the repository we downloaded before with
        
        ```
        cd /mnt/c/Users/[your windows username]/Documents/bls-query-app
        ```

    5) *Important:* you can paste from you windows clip board into wsl by
    right-clicking. You will likely find this very useful.


#### 2) Ruby 2.5.7
1) Install gpg2 (a prerequisite for rvm)

    ```
    sudo apt-get install gnupg2
    ```
    Note: unless otherwise specified all of these instructions are meant
    to be run in the Ubuntu installation you just set up.

2) Install rvm (based on [these instructions](https://rvm.io/))

    ```
    gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    \curl -sSL https://get.rvm.io | bash -s stable
    ```

3) Close your bash shell and open a new one (or `source ~/.bashrc` should work)

4) Install Ruby 2.7.0 (this will take a while)

    ```
    rvm install 2.7.0
    ```

5) Set default Ruby version

    ```
    bash --login
    rvm --default use 2.7.0
    ```

6) Close and re-open WSL

7) Check installation

    ```
    rvm list
    ```
    You should see `=* ruby-2.7.0` in the output.

#### 3) Rails 6.0.2
1) Install nodejs (a prerequisite)

    ```
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt-get install -y nodejs
    ```

2) Install Rails 6.0.2 (this will take a while)

    ```
    gem install rails -v=6.0.2
    ```


## 3) Run Application 
### Then run the application.

1) Go to the folder 'bls-query-app' in Documents from the Ubuntu shell

    ```
    cd /mnt/c/Users/[your windows username]/Documents/bls-query-app
    ```

2) Now go into the repository (folder) you downloaded from the GitHub page

    ```
    cd prototype-1
    ```
    
3) Install the new app's dependencies

    ```
    bundle install
    ```
    You may have to try this command multiple times. If it fails in a
    consistent way then seek help. Some references to help with issues are:
        
        - Stack Overflow: https://stackoverflow.com/
        - Ruby and Rails Documentation: https://rubyapi.org/
        - Google: https://www.google.com/

4) Run the application

    ```
    rails server
    ```

    *** If there is an issue with the 'yarn' dependency then please run:

    ```
    yarn install --check-files
    ```

    If there are even more issues please look to this page:
    https://linuxize.com/post/how-to-install-yarn-on-ubuntu-18-04/

    Note that there might need to be repeated attempts to work.
    
    If you have fixed the issue, re-run the application.

    ***
    

5) Open your browser and put [localhost:3000](localhost:3000) in the
address bar (or open the link)

    There you should see the BLS Homepage. 

    Congrats, you did it! (When you're done the key combination CTRL c
    in the Ubuntu shell to stop the server)


## 4) Logging into the Application
### The last step is logging into the application

1) Setup the default database

    Stop the rails server with the step above and in your Ubuntu shell run:
    
    ```
    rails db:setup
    ```
    
    This will allow for rudimentary user with:
        
        username: admin
        password: secret

2) To set up your own account with personal api key

    1) Run the rails console by typing in:

        ```
        rails c
        ```

    2) Afterwards run the following commands one at a time:
    (Where there is a <>, that is where you put your own input, exclude the <> in the quotations
     ex. a.username = "janedoe_username")

        ```
        a = User.new
        a.username = “<personal username insert here>”
        a.password = “<personal password insert here>”
        a.password_confirmation = “<password from above>”
        a.api_key = “<your api key>”
        a.admin = true
        a.save
        ```
        Then quit out of the rails console with:

        ```
        quit
        ```

    3) Re-run the server now

        ```
        rails server
        ```

        And you should have access to your own account with your own api-key!


## Author's Note

This specific document was written by a member of the 373 ACCD Spring 2020 Group.
Contact: jli6@andrew.cmu.edu

Fellow 272 TA, Matt Kern, created most of the documentation for the IS class 272: Application Design and Development. The are steps to download Ruby on Rails onto a Windows Machine are mostly his work 
but some steps are adjusted to fit the ACCD's needs.
Reference: https://github.com/mjkern/67272-Windows-Setup/blob/master/instructions.md
Contact: mjkern@andrew.cmu.edu


