export const sanitizeStepRouteParameter = (to, firstStep, lastStep, forceFirstStep=false, stepParameter="step") => {
	let query = to.query;
	let step = parseInt(to.query[stepParameter]);

	if (isNaN(step) || step < firstStep || step > lastStep || (forceFirstStep && step != firstStep)) {
		query[stepParameter] = firstStep;
		return { path: to.path, query };
	} else {
		return true;
	}
}
