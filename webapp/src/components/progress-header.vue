<template lang="pug">
  div(v-if="maxStep != minStep")
    h6.text-muted(v-if="!hideLabel" name="progress-label") {{ 	$t('step', {step: displayStep, total: displayMaxStep}) }}
    b-progress(
      :max="displayMaxStep"
      :value="displayStep"
      variant="success"
      height="20px"
    )
</template>
<script>
    export default {
        props: {
            hideLabel: {
                type: Boolean,
                default: false
            },
            step: {
                type: Number,
                required: true
            },
            maxStep: {
                type: Number,
                required: true
            },
            minStep: {
                type: Number,
                default: 1
            }
        },
        computed: {
            displayStep() {
                return this.step - this.minStep + 1
            },
            displayMaxStep() {
                return this.maxStep - this.minStep + 1
            }
        }
    }
</script>
