{{--
    Abstract brand background for the admin panel: soft mustard and teal glows, orbit rings
    and a wave, drawn behind the content. Light and dark variants; it never captures clicks.
--}}
<style>
    body.fi-body {
        background-repeat: no-repeat;
        background-size: cover;
        background-attachment: fixed;
    }

    html:not(.dark) body.fi-body {
        background-color: #fffdf5;
        background-image:
            radial-gradient(900px 560px at 100% -10%, rgba(212, 160, 23, .34), transparent 62%),
            radial-gradient(720px 520px at -8% 108%, rgba(212, 160, 23, .22), transparent 62%),
            radial-gradient(560px 440px at 76% 112%, rgba(15, 76, 92, .18), transparent 64%),
            url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='1440' height='900' viewBox='0 0 1440 900' fill='none'><g stroke='%23D4A017' stroke-width='1.4'><circle cx='1220' cy='-30' r='250' stroke-opacity='.36'/><circle cx='1220' cy='-30' r='370' stroke-opacity='.26'/><circle cx='1220' cy='-30' r='500' stroke-opacity='.18'/></g><g stroke='%230F4C5C' stroke-width='1.2'><circle cx='120' cy='930' r='220' stroke-opacity='.24'/><circle cx='120' cy='930' r='340' stroke-opacity='.16'/></g><path d='M0 780 C 260 700 540 860 820 780 S 1250 710 1440 790 L1440 900 L0 900 Z' fill='%23D4A017' fill-opacity='.12'/></svg>");
    }

    html.dark body.fi-body {
        background-color: #09090b;
        background-image:
            radial-gradient(900px 560px at 100% -10%, rgba(212, 160, 23, .20), transparent 62%),
            radial-gradient(720px 520px at -8% 108%, rgba(212, 160, 23, .10), transparent 62%),
            radial-gradient(560px 440px at 76% 112%, rgba(30, 130, 150, .16), transparent 64%),
            url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' width='1440' height='900' viewBox='0 0 1440 900' fill='none'><g stroke='%23F0C94C' stroke-width='1.4'><circle cx='1220' cy='-30' r='250' stroke-opacity='.20'/><circle cx='1220' cy='-30' r='370' stroke-opacity='.13'/><circle cx='1220' cy='-30' r='500' stroke-opacity='.08'/></g><g stroke='%2347B7C9' stroke-width='1.2'><circle cx='120' cy='930' r='220' stroke-opacity='.16'/><circle cx='120' cy='930' r='340' stroke-opacity='.10'/></g><path d='M0 780 C 260 700 540 860 820 780 S 1250 710 1440 790 L1440 900 L0 900 Z' fill='%23D4A017' fill-opacity='.06'/></svg>");
    }

    /* The shell panels stay readable over the artwork. */
    html:not(.dark) .fi-topbar,
    html:not(.dark) .fi-sidebar {
        background-color: rgba(255, 253, 245, .86);
        backdrop-filter: blur(10px);
    }

    html.dark .fi-topbar,
    html.dark .fi-sidebar {
        background-color: rgba(9, 9, 11, .82);
        backdrop-filter: blur(10px);
    }
</style>
