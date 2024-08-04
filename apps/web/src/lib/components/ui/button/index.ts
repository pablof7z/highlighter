import { type VariantProps, tv } from "tailwind-variants";
import type { Button as ButtonPrimitive } from "bits-ui";
import Root from "./button.svelte";

const buttonVariants = tv({
	base: "inline-flex items-center justify-center whitespace-nowrap rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
	variants: {
		variant: {
			default: "bg-primary text-primary-foreground hover:bg-primary/90 max-sm:!text-primary-foreground",
			destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90",
			accent: "bg-accent text-accent-foreground hover:bg-accent/90 max-sm:!bg-accent",
			outline:
				"border border-input bg-background",
			secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
			ghost: "hover:bg-primary hover:text-primary-foreground",
			link: "text-primary underline-offset-4 hover:underline",
			gold: "border border-gold bg-background/10 hover:bg-background hover:text-foreground text-gold",
			transparent: "border border-input bg-background/10 hover:bg-background hover:text-foreground",
		},
		size: {
			default: "h-10 px-4 py-2 max-sm:text-lg",
			xs: "h-7 text-xs rounded-md px-3",
			sm: "h-9 rounded-md px-3",
			lg: "h-14 rounded-md px-8 text-base",
			icon: "h-10 w-10",
		},
	},
	defaultVariants: {
		variant: "default",
		size: "default",
	},
});

type Variant = VariantProps<typeof buttonVariants>["variant"];
type Size = VariantProps<typeof buttonVariants>["size"];

type Props = ButtonPrimitive.Props & {
	variant?: Variant;
	size?: Size;
};

type Events = ButtonPrimitive.Events;

export {
	Root,
	type Props,
	type Events,
	//
	Root as Button,
	type Props as ButtonProps,
	type Events as ButtonEvents,
	buttonVariants,
};
