export type WarningItem = {
    message: string;
    showStopper?: boolean;
    link?: {
        text: string;
        fn: () => void;
    }
}