<svg width="365" height="411" viewBox="55 80 255 250" fill="none" xmlns="http://www.w3.org/2000/svg" class={$$props.class || ``}>
    <defs>
        <!-- Glow Filter -->
        <filter id="glow" x="-50%" y="-50%" width="200%" height="200%">
            <feGaussianBlur in="SourceAlpha" stdDeviation="2.5" result="blur"/>
            <feMerge>
                <feMergeNode in="blur"/>
                <feMergeNode in="SourceGraphic"/>
            </feMerge>
        </filter>

        <linearGradient id="paint0_linear_1061_7577" x1="267.686" y1="74.6531" x2="115.153" y2="306.279" gradientUnits="userSpaceOnUse">
            <stop stop-color="#FF7E34"/>
            <stop offset="1" stop-color="#FF5E69"/>
        </linearGradient>
    </defs>

    <g id="Group 55">
        <!-- Background Shape with Opacity -->
        <path id="Vector" d="M229.293 192.585L196.391 194.264V140.437C196.391 135.042 189.571 134.083 186.699 138.879L137.166 215.603C135.132 218.72 137.166 223.635 140.875 223.635L168.274 223.395V274.944C168.274 280.099 174.615 282.497 177.367 278.421L233.6 201.696C236.831 197.381 234.079 192.346 229.293 192.585Z" fill="#FF685E" fill-opacity="0.7"/>

        <!-- Foreground Shape with Gradient and Glow Effect -->
        <g id="Vector_2" filter="url(#glow)">
            <path d="M225.932 189.807L193.029 191.485V137.658C193.029 132.264 186.21 131.305 183.338 136.1L133.805 212.824C131.771 215.941 133.805 220.856 137.514 220.856L164.913 220.616V272.165C164.913 277.32 171.254 279.718 174.006 275.642L230.239 198.918C233.469 194.602 230.718 189.567 225.932 189.807Z" fill="url(#paint0_linear_1061_7577)"/>
        </g>
    </g>
</svg>

<!-- CSS to Animate the Glow Effect -->
<style>
    @keyframes glowAnimation {
        0%, 100% {
            filter: drop-shadow(0 0 0px #FF685Ea0) drop-shadow(0 0 5px #FF685Ea0) drop-shadow(0 0 20px #FF685Ea0);
        }
        50% {
            filter: drop-shadow(0 0 0px #FF685Ea0) drop-shadow(0 0 15px #FF685Ea0) drop-shadow(0 0 22px #FF685Ea0);
        }
    }

    #Vector_2 path {
        animation: glowAnimation 2s infinite;
    }
</style>
