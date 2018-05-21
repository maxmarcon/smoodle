export const sanitizeStepRouteParameter = (to, firstStep, lastStep, forceFirstStep=false, stepParamter="step") => {
	let query = to.query;
	let step = parseInt(to.query[stepParamter]);

	if (isNaN(step) || step < firstStep || step > lastStep || (forceFirstStep && step != firstStep)) {
		query[stepParamter] = firstStep;
		return { path: to.path, query };
	} else {
		return true;
	}
}
