## Freshdesk HipChat Addon

Freshdesk HipChat addon is a middleware app to notify the HipChat room when tickets in freshdesk are created or updated.

This integration is written as a rails app. The tutorial explains deploying the app on [heroku](https://www.heroku.com)--alternatively, you can deploy this in any other host. The app must be web-accessible (cannot run in a internal network / localhost). After deploying, HipChat needs to be configured--covered in section after deployment.

### 1. Deploying app on heroku:

1. [Signup for Heroku](https://id.heroku.com/signup/www-header).
2. [Download Heroku Toolbelt](https://toolbelt.heroku.com). This is the heroku commandline tool.
3. Clone the freshdesk hipchat addon from github with `git clone git@github.com:freshdesk/hipchat_freshdesk_addon.git`.
4. Edit `config/environment.rb` and change the `ENV["DOMAIN"]` with the heroku app name, eg _http://your-hipchat-addon.herokuapp.com_.
5. Do `git init`.
6. Do `git add .`
7. Do `git commit -m "Initial import of freshdesk hipchat addon"`
8. Do `heroku login`
9. Once authenticated, you will be requested to configure and share your public key with heroku.
9. Do `heroku create <your-hipchat-addon>`. `<your-hipchat-addon>` is the app name in heroku also which is mentioned in `environment.rb`.
10. Do `git push heroku master`
11. Do `heroku logs` to see the logs from heroku.

To test if the addon is deployed successfully, point your browser to `http://your-hipchat-addon.herokuapp.com/hipchat`. You should see a JSON response.

### 2. Configuring HipChat to use freshdesk-hipchat addon

1. Login to HipChat. Go to the rooms tab, and select the room where Freshdesk notifications needs to be published.
2. Select _Integrations_ menu link in the left navigation.
3. Click on the link _Build and install your own integration_.
4. You will be prompted to provide the integration URL. Give the URL `http://your-hipchat-addon.herokuapp.com/hipchat`. Click on _Add integration_.
5. You will be shown the Freshdesk configuration screen, where you need to provide:
    1. Freshdesk domain and API key.
    2. Choose on what event the notifications must be triggered--only on ticket create or on update too.

