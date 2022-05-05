# Craft CMS + Digital Ocean App Platform

(Almost) one-click infrastructure for Craft CMS applications!

[![Deploy to Digital Ocean](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/oof-bar/craftcms-do-apps/tree/main)

> Psst! This button looks like it works, but you'll probably encounter one of about a dozen cryptic errors when trying to create your app—mostly having to do with [limitations of the App Spec system](https://docs.digitalocean.com/products/app-platform/how-to/add-deploy-do-button/#limits) for one-click deploys. It's best to just fork this repo and create a new App from within your Digital Ocean account.


## What's all this, then?

We've been fans of [twelve-factor apps](https://12factor.net/) for a while now. To-date, Heroku has been our platform of choice due to its mature tooling and reliability—but it's expensive and slow. In some cases, the tradeoffs were acceptable—when we needed rock-solid support, uptime, and scalability, there really wasn't an alternative.

However, Digital Ocean's new [App Platform](https://www.digitalocean.com/products/app-platform/) changes that.

Built on the same principles as Heroku (even down to the open-source [buildpack](https://docs.digitalocean.com/products/app-platform/build-system/cloud-native-buildpacks/) concept), the product is immediately familiar. So similar, in fact, that our [Heroku Starterkit](https://github.com/oof-bar/craft-heroku) nearly worked out-of-the-box.

Here's what feels good:

1. **Component types.** Web, Worker, and “Job” (_Release_, in Heroku parlance) types are available now, and it seems like they're primed to add more (including perhaps to resolve one of our issues, mentioned below).
2. **Scalability.** I'll roll in _value_ here, too—because scaling wouldn't be a concern if it wasn't directly linked to cost. Being able to take advantage of the architecture with a lower buy-in is awesome for smaller projects. And for critical apps with predictable traffic surges, it's just as easy to increase capacity. We are missing the auto-scaling feature, though—which admittedly was a bit of a bust on Heroku.
3. **Performance.** Even with cut-rate provisioning, Craft feels quick. I suspect this is largely thanks to the significantly faster managed Postgres instances that Digital Ocean offers. What gives, Heroku?

There are some differences, though, and some significantly impact the dev/ops experience:

1. **Build times.** I wish I could explain why it takes 15–20 minutes to package and build a new image for deployment. Our [typical deployments](https://deployer.org) targeting standard VPS instances are often less than a minute, and even on Heroku, whatever build-time Dyno they supplied seemed to be able to integrate code and infrastructure changes in a few minutes.
2. **Databases.** Ultimately, you manage databases in the regular Cloud dashboard, then "add" them to an app, exposing some aliases to make connections easier—but those resources have to be completely open to the web (behind only some mediocre passwords) to be compatible with the App Platform. No more scoping connections to other Components via the UI, as you might for a VPS.
3. **The UI.** Something feels fundamentally broken about the in-browser experience. Safari threads will crash, drop sockets, or otherwise lock up multiple times per session. I've had to hard-refresh most interfaces to be sure I'm seeing the right state, and sometimes the app won't even reinitialize correctly based on my last known (or presumed) location.
4. **Scheduled Jobs.** No first-party Component type for CRON may be a non-starter for some applications. If you only need a persistent Queue worker, then you're set—but any kind of scheduled task will be a challenge without some additional work. For the time being, a $5/mo barebones Droplet with a `crontab` can ping a Craft/Yii controller easily enough… until [an official solution](https://www.digitalocean.com/blog/introducing-digitalocean-app-platform-reimagining-paas-to-make-it-simpler-for-you-to-build-deploy-and-scale-apps/) rolls around.


## How does this differ from a normal Craft installation?

A few things make this kind of infrastructure unique—and they all relate to the environments (web, worker, or otherwise) being both multiple _and_ ephemeral.

This means:

- We can't store anything on the filesystem that we're not comfortable losing in the normal lifecycle of an individual node;
- Anything that multiple nodes need to access (like sessions or caches) must be kept in a common location, like the database or Redis;
- We may not have command-line access to a specific node;
- Individualized configuration is not possible per-node;
- Logs that are not streamed to `stdout` are effectively unreachable or incomplete;

You'll notice a couple of extra packages on top of the two in the [Craft starterkit](https://github.com/craftcms/craft).

### `yiisoft/yii2-redis`

This is the first-party Redis adapter for Yii 2. As with logs, we configure the base Redis instance within `app.php`.

> At the moment, direct use of the `REDIS_URL` connection string is not possible, despite the components being packed back into something that looks a lot like what's provided by the platform.

We also replace the default Session and Mutex components with the ones provided in the package, ensuring Craft's `SessionBehavior` is applied to the former.


## But how do I get it working?

As alluded to in the opening paragraph, the "one-click" feature of the App Platform has a ways to go, in terms of feature parity with the apps you can configure from scratch in your account. Don't worry, though—it's still pretty simple.

Prior to getting started, you'll need to create two database clusters: one MySQL or Postgres, and one Redis.

1. Fork this repo, or clone + push it to a new remote;
2. Connect your GitHub account to the Digital Ocean account you want the app to live in;
3. Start the process of creating a [new app](https://docs.digitalocean.com/products/app-platform/how-to/create-apps/), and select the new repo as the source;
4. Some settings will be detected—but here are the important things to update:
  - Run Command: Either `heroku-php-nginx -C nginx.conf web/` for nginx or `heroku-php-apache2 -C apache.conf web/`;
  - Environment Variables: Check `.do/deploy.template.yaml` for the keys that should be defined! Some will be auto-populated by the platform (like app and database URLs), but others (Craft-specific keys) require manual entry;
  - Services: The web service is configured automatically—but you'll have to attach the database + Redis services manually, after-the-fact;
5. If an initial deploy is started, you might as well cancel it—it won't succeed! Deploys are triggered after adding your databases, anyway—keep in mind that you may see additional failures if one is attached, but not the other. No way around this, as far as I can tell.

> :lightbulb: After you've finished setting up the app, you can set up limitations on your database(s) to ensure only you and the app platform are able to access them.

:deciduous_tree:
