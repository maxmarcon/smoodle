<template lang="pug">
  b-alert(
    :show="dismissCountDown"
    fade
    :dismissible="seconds <= 0"
    :variant="variant"
    @dismissed="dismissCountDown = false"
    @dismiss-count-down="countDownChanged"
  ) {{ errorMsg }}
</template>

<script>
    export default {
        props: {
            seconds: {
                type: Number,
                default: 5
            },
            variant: {
                type: String,
                default: "info"
            }
        },
        data: () => ({
            dismissCountDown: 0,
            errorMsg: null
        }),
        methods: {
            countDownChanged(dismissCountDown) {
                this.dismissCountDown = dismissCountDown;
            },
            show(msg, showNativeNotification) {
                this.errorMsg = msg;
                this.dismissCountDown = (this.seconds > 0 ? this.seconds : true);
                if (showNativeNotification && Notification) {
                  new Notification(this.$i18n.t('app_name'), {icon: '/favicon.ico', body: msg})
                }
            }
        }
    }
</script>