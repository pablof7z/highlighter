<script lang="ts">
	import RadioButton from "$components/Forms/RadioButton.svelte";
	import { Button } from "$components/ui/button";

    let mode: string = "tiers";
</script>

<div class="flex flex-col h-full w-full fixed top-0 bottom-0 left-0 right-0 justify-center items-center">
        <div class="flex flex-col">
            <h3 class="text-lg text-muted-foreground">
                How would you like your subscribers to support you?
            </h3>
        </div>
        
        <RadioButton bind:currentValue={mode} value="tiers" class="text-lg p-6">
            Tiers
        </RadioButton>
    
        <RadioButton bind:currentValue={mode} value="v4v" class="text-lg p-6">
            Value-for-value
        </RadioButton>

        <Button variant="accent" size="lg">
            Continue
        </Button>
</div>