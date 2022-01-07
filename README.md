# Craft CMS + Digital Ocean App Platform

One-click infrastructure for Craft CMS applications!

[![Deploy to Digital Ocean](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/oof-bar/craftcms-do-apps/tree/main)

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

We also replace the default Sessions component with the one provided in the package, ensuring Craft's `SessionBehavior` is applied along with it.

:deciduous_tree:
