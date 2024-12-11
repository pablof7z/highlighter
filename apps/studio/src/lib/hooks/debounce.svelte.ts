export const useDebounce = (initialValue: any, delay: number = 250) => {
    let timeout = $state<any | null>(null);
    let value = $state<any>(initialValue);
    let loading = $state<boolean>(false);
  
    const update = (newValue: any) => {
      if (timeout) clearTimeout(timeout);
      loading = true;
  
      timeout = setTimeout(() => {
        value = newValue;
        loading = false;
      }, delay);
    };
  
    return {
      get value() {
        return value;
      },
      update,
      get loading() {
        return loading;
      },
    };
};  