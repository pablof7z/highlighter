<script>
    import {
      Page,
      Navbar,
      Block,
      Button,
      List,
      ListItem,
      BlockTitle,
    } from 'konsta/svelte';
  </script>
  
  <Page>
    <Navbar title="My App" />
  
    <Block strong>
      <p>Here is your SvelteKit & Konsta UI app. Let's see what we have here.</p>
    </Block>
    <BlockTitle>Navigation</BlockTitle>
    <List>
    </List>
  
    <Block strong class="flex space-x-4">
      <Button>Button a</Button>
      <Button>Button 2</Button>
    </Block>
  </Page>