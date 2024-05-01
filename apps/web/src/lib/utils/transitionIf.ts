type ConditionalTransition = {
    cond: boolean;
    fn: (node: HTMLElement, opts: any) => void;
    options?: any;
}

export default function(node: HTMLElement, opts: ConditionalTransition) {
    console.log(opts);
    if (opts.cond) {
        return opts.fn(node, opts.options);
    }
}