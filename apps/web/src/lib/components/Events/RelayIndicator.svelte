<script lang="ts">
    export let relay: string;

    // deterministically generate a color based on the relay
    function getRelayColor() {
        const colors = [
            "bg-red-500",
            "bg-yellow-500",
            "bg-green-500",
            "bg-blue-500",
            "bg-indigo-500",
            "bg-purple-500",
            "bg-pink-500",
        ];

        // generate a number based on the relay url
        const numb = relay.split("").reduce((acc, char) => acc + char.charCodeAt(0), 0);
        const colorIndex = numb % colors.length;
        return colors[colorIndex];
    }
</script>

<div class="w-3 h-3 rounded-full {getRelayColor()} tooltip" data-tip={relay}></div>