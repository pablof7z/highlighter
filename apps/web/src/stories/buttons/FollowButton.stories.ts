import type { Meta, StoryObj } from '@storybook/svelte';

import FollowButton from '$components/buttons/FollowButton.svelte';
import NDK, { NDKPrivateKeySigner } from '@nostr-dev-kit/ndk';

const ndk = new NDK({explicitRelayUrls: ['wss://nos.lol']})
ndk.signer = NDKPrivateKeySigner.generate();
const user = ndk.getUser({npub: "npub1l2vyh47mk2p0qlsku7hg0vn29faehy9hy34ygaclpn66ukqp3afqutajft"})

// More on how to set up stories at: https://storybook.js.org/docs/svelte/writing-stories/introduction
const meta = {
  title: 'Buttons/Follow Button',
  component: FollowButton,
  tags: ['autodocs'],
  argTypes: {
    backgroundColor: { control: 'color' },
    size: {
      control: { type: 'select' },
      options: ['small', 'medium', 'large'],
    },
  },
} satisfies Meta<FollowButton>;

export default meta;
type Story = StoryObj<typeof meta>;

// More on writing stories with args: https://storybook.js.org/docs/svelte/writing-stories/args
export const Primary: Story = {
  args: {
    user
  },
};

export const Secondary: Story = {
  args: {
    label: 'FollowButton',
  },
};

export const Large: Story = {
  args: {
    size: 'large',
    label: 'FollowButton',
  },
};

export const Small: Story = {
  args: {
    size: 'small',
    label: 'FollowButton',
  },
};
