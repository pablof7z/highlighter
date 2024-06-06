import { type VariantProps, tv } from "tailwind-variants";
export { default as Badge } from "./badge.svelte";

export const badgeVariants = tv({
	base: "inline-flex select-none items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-ring focus:ring-offset-2",
	variants: {
		variant: {
			default: "border-transparent bg-primary text-primary-foreground hover:bg-primary",
			secondary:
				"border-transparent bg-secondary text-secondary-foreground hover:bg-secondary",
			destructive:
				"border-transparent bg-destructive text-destructive-foreground hover:bg-destructive",
			outline: "text-foreground",
		},
	},
	defaultVariants: {
		variant: "default",
	},
});

export type Variant = VariantProps<typeof badgeVariants>["variant"];
