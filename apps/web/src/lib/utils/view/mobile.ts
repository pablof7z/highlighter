import Device from 'svelte-device-info';

// export function initializeMobileView(window: Window) {
//     setupIonicSvelte();
//     defineCustomElements(window);
// }

/**
 * Returns true if the app is being built for a mobile exclusively.
 */
export function isMobileBuild() {
    return true;
    return !!import.meta.env.VITE_MOBILE;
}

export function isPhone() {
    // for development we can force the phone view when running
    // in the iOS Simulator
    if (process.env.NODE_ENV === 'development' && typeof navigator !== 'undefined') {
        const userAgent = navigator?.userAgent;
        if (userAgent?.includes('iPhone')) {
            return true;
        }
    }

    if (typeof navigator === 'undefined') return false;

    return Device.isPhone
}