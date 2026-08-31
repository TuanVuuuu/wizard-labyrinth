const WL_DEPLOY_VERSION_URL = 'wl_deploy_version.json';
const WL_DEPLOY_POLL_MS = 15000;
const WL_DEPLOY_RELOAD_KEY = 'wl_last_reload_version';
const WL_DEPLOY_STORAGE_KEY = 'wl_deploy_version';

function wlEmbeddedDeployVersion() {
  return document.documentElement.dataset.wlDeployVersion ?? '';
}

function wlIsLocalPlaceholder(version) {
  return version.length === 0 || version === 'WL_DEPLOY_VERSION';
}

async function wlClearStaleWebCache() {
  try {
    if ('serviceWorker' in navigator) {
      const registrations = await navigator.serviceWorker.getRegistrations();
      await Promise.all(
        registrations.map((registration) => registration.unregister()),
      );
    }
    if (window.caches) {
      const cacheNames = await caches.keys();
      await Promise.all(cacheNames.map((name) => caches.delete(name)));
    }
  } catch (_) {}
}

async function wlFetchDeployVersion() {
  try {
    const response = await fetch(
      `${WL_DEPLOY_VERSION_URL}?t=${Date.now()}`,
      { cache: 'no-store' },
    );
    if (!response.ok) {
      return '';
    }
    const payload = await response.json();
    const version = payload.version;
    if (typeof version !== 'string' || version.length === 0) {
      return '';
    }
    return version;
  } catch (_) {
    return '';
  }
}

function wlLoadFlutter(version) {
  const script = document.createElement('script');
  const cacheBust = wlIsLocalPlaceholder(version)
    ? String(Date.now())
    : version;
  script.src = `flutter_bootstrap.js?v=${encodeURIComponent(cacheBust)}`;
  script.async = true;
  document.body.appendChild(script);
}

function wlReloadForNewDeploy(remoteVersion) {
  const lastReloadVersion = sessionStorage.getItem(WL_DEPLOY_RELOAD_KEY);
  if (lastReloadVersion === remoteVersion) {
    return false;
  }
  sessionStorage.setItem(WL_DEPLOY_RELOAD_KEY, remoteVersion);
  const nextUrl = new URL(window.location.href);
  nextUrl.searchParams.set('wl_reload', remoteVersion);
  window.location.replace(nextUrl.toString());
  return true;
}

async function wlCheckDeployVersion(embeddedVersion) {
  if (wlIsLocalPlaceholder(embeddedVersion)) {
    return false;
  }
  const remoteVersion = await wlFetchDeployVersion();
  if (remoteVersion.length === 0) {
    return false;
  }
  if (remoteVersion === embeddedVersion) {
    return false;
  }
  return wlReloadForNewDeploy(remoteVersion);
}

function wlWatchDeployVersion(embeddedVersion) {
  const check = () => {
    wlCheckDeployVersion(embeddedVersion);
  };
  setInterval(check, WL_DEPLOY_POLL_MS);
  document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') {
      check();
    }
  });
}

async function wlStartWeb() {
  await wlClearStaleWebCache();
  const embeddedVersion = wlEmbeddedDeployVersion();
  const storedVersion = localStorage.getItem(WL_DEPLOY_STORAGE_KEY) ?? '';

  if (
  !wlIsLocalPlaceholder(embeddedVersion) &&
  storedVersion.length > 0 &&
  storedVersion !== embeddedVersion
  ) {
    await wlClearStaleWebCache();
  }

  const isReloading = await wlCheckDeployVersion(embeddedVersion);
  if (isReloading) {
    return;
  }

  if (!wlIsLocalPlaceholder(embeddedVersion)) {
    localStorage.setItem(WL_DEPLOY_STORAGE_KEY, embeddedVersion);
  }

  wlLoadFlutter(embeddedVersion);
  wlWatchDeployVersion(embeddedVersion);
}

wlStartWeb();
