import { createApp } from 'vue';
import { Quasar, Dialog, Notify } from 'quasar';
import quasarLangSl from 'quasar/lang/sl';
import '@quasar/extras/material-icons/material-icons.css';
import 'quasar/dist/quasar.css';
import './styles.css';
import App from './App.vue';

createApp(App)
  .use(Quasar, {
    lang: quasarLangSl,
    plugins: {
      Dialog,
      Notify
    }
  })
  .mount('#app');
