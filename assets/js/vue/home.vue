.<template lang="pug">
	div
		.card
			.card-header.text-center
				h1.card-title.text-success
					em {{ $t('app_name') }}
				h5.card-title.text-muted {{ $t('home.title') }}
			.card-body.text-center
				.row.align-items-center
					.col-md-6.mt-2
						.p-3.border.border-success.rounded.card-text.text-muted
							i18n(path="home.subtitle_1" tag="em")
								span.text-success(place="app_name") {{ $t('app_name') }}
					.col-md-6.mt-2
						.p-3.border.border-success.rounded.card-text.text-muted
							em {{ $t('home.subtitle_2') }}
				.justify-content-center.mt-2
					.p-3
							h5.card-title.text-info {{ $t('home.how_it_works') }}
				.card-deck
					.card
						.card-header
							i18n.card-title.text-muted(path="home.step1.title" tag="h6")
								span.h5.text-primary(place="step") {{ $t('home.step', {step: 1})}}
						.card-body
							ul.list-group.list-group-flush
								li.list-group-item.text-muted
									em {{ $t('home.step1.part1') }}
								li.list-group-item.text-muted
									em {{ $t('home.step1.part2') }}
								li.list-group-item
									img.img-fluid.w-75.border.border-primary.rounded(:src="fullPath('event_creation_calendar.png')")
								li.list-group-item.text-muted
									em {{ $t('home.step1.part3') }}
					.card
						.card-header
							i18n.card-title.text-muted(path="home.step2.title" tag="h6")
								span.h5.text-primary(place="step") {{ $t('home.step', {step: 2})}}
						.card-body
							ul.list-group.list-group-flush
								li.list-group-item.d-flex.justify-content-around.pb-4
									i.icon.fas.fa-thumbs-up.fa-2x.text-success
									i.icon.fas.fa-circle.fa-2x.text-warning
									i.icon.fas.fa-thumbs-down.fa-2x.text-danger
								li.list-group-item.text-muted
									i18n(path="home.step2.part1" tag="em")
										span.text-success(place="good") {{ $tc('home.good', 1) }}
										span.text-warning(place="indifferent") {{ $tc('home.indifferent', 1) }}
										span.text-danger(place="bad") {{ $tc('home.bad', 1) }}
								li.list-group-item.text-muted
									em {{ $t('home.step2.part2') }}

					.card
						.card-header
							i18n.card-title.text-muted(path="home.step3.title" tag="h6")
								span.h5.text-primary(place="step") {{ $t('home.step', {step: 3})}}
						.card-body
							ul.list-group.list-group-flush
								li.list-group-item.text-muted
									em {{ $t('home.step3.part1') }}
								li.list-group-item
									img.img-fluid.w-75.border.border-success.rounded(:src="fullPath('event_overview_calendar.png')")
								li.list-group-item.text-muted
									i18n(path="home.step3.part2" tag="em")
										span.text-success(place="good") {{ $tc('home.good_upper', 2) }}
										span.text-danger(place="bad") {{ $tc('home.bad', 2) }}
								li.list-group-item.text-muted
									em {{ $t('home.step3.part3') }}

			.card-footer
				.row.justify-content-center
					router-link.btn.btn-success(
						role="button"
						:to="{ name: 'new_event'}"
					)
						i.fas.fa-plus
						| &nbsp; {{ $t('home.create_new_event') }}

</template>
<script>
import { imageHelpersMixin } from '../globals'

export default {
	mixins: [imageHelpersMixin]
}
</script>