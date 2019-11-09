import RestMixin from '../../src/mixins/rest'
import {shallowMount} from '@vue/test-utils'

const dummyComponent = {
    render() {
    },
    mixins: [RestMixin]
};

let axiosStub, showInErrorBarStub, loadingStub, loaderStub
let wrapper, requestResult, rethrownError, axiosError;

describe('RestMixin', () => {

    beforeEach(() => {
        jasmine.clock().install();

        axiosStub = jasmine.createSpyObj('axios', ['request']);
        showInErrorBarStub = jasmine.createSpy('showInErrorBar');
        loadingStub = jasmine.createSpyObj('$loading', ['show']);
        loaderStub = jasmine.createSpyObj('loader', ['hide'])
        loadingStub.show.and.returnValue(loaderStub)

        wrapper = shallowMount(dummyComponent, {
            mocks: {
                $i18n: {
                    locale: 'en',
                    t: (key) => key
                },
                $http: axiosStub,
                $loading: loadingStub,
                showInErrorBar: showInErrorBarStub
            }
        });
    });

    afterEach(() => {
        jasmine.clock().uninstall();
    })

    it('has an API version', () => {
        expect(wrapper.vm.apiVersion).toBeTruthy()
    });

    it('initially there is no ongoing request', () => {
        expect(wrapper.vm.requestOngoing).toBeFalse()
    });

    describe('when executing a request', () => {

        beforeEach(() => {
            axiosStub.request.and.returnValue(Promise.resolve("RESPONSE"))

            requestResult = wrapper.vm.restRequest('api/endpoint', {
                method: 'post',
                params: {
                    foo: "foo"
                }
            });
        })

        it('calls axios with the right parameters', () => {
            expect(axiosStub.request).toHaveBeenCalledWith(jasmine.objectContaining({
                url: '/v1/api/endpoint',
                method: 'post',
                params: {
                    foo: 'foo'
                },
                headers: {
                    'Accept-Language': 'en'
                },
            }))
        });

        it('returns a promise that resolves to the response', async () => {
            expect(requestResult).toEqual(jasmine.any(Promise));
            const response = await requestResult;
            expect(response).toEqual("RESPONSE")
        });

        it('marks the request as ongoing', () => {
            expect(wrapper.vm.requestOngoing).toBeTrue();
        });

        it('shows the loading overlay after 100 msec', () => {
            jasmine.clock().tick(105)
            expect(loadingStub.show).toHaveBeenCalled()
        });

        describe('after the request completes', () => {

            it('marks the request as not ongoing after the promise resolves', async () => {
                await requestResult;
                expect(wrapper.vm.requestOngoing).toBeFalse();
            })

            it('cancels the loading overlay', async () => {
                jasmine.clock().tick(105)
                await requestResult
                expect(loaderStub.hide).toHaveBeenCalled()
            });
        })
    })

    describe('for background requests', () => {

        beforeEach(() => {
            axiosStub.request.and.returnValue(Promise.resolve("RESPONSE"))

            requestResult = wrapper.vm.restRequest('api/endpoint', {
                method: 'post',
                params: {
                    foo: "foo"
                },
                background: true
            });
        })

        it('does not mark the request as ongoing', () => {
            expect(wrapper.vm.requestOngoing).toBeFalse();
        });

        it('does not show the loading overlay after 100 msec', () => {
            jasmine.clock().tick(105)
            expect(loadingStub.show).not.toHaveBeenCalled()
        });

        describe('after the request completes', () => {

            it('the request is still not marked as ongoing after the promise resolves', async () => {
                await requestResult;
                expect(wrapper.vm.requestOngoing).toBeFalse();
            })

            it('does not cancel the loading overlay', async () => {
                jasmine.clock().tick(105)
                await requestResult
                expect(loaderStub.hide).not.toHaveBeenCalled()
            });
        })
    });

    describe('without VueLoading', () => {

        beforeEach(() => {
            wrapper = shallowMount(dummyComponent, {
                mocks: {
                    $i18n: {
                        locale: 'en',
                        t: (key) => key
                    },
                    $http: axiosStub,
                    showInErrorBar: showInErrorBarStub
                }
            });

            axiosStub.request.and.returnValue(Promise.resolve("RESPONSE"))

            requestResult = wrapper.vm.restRequest('api/endpoint', {
                method: 'post',
                params: {
                    foo: "foo"
                }
            });
        })

        it('does not show the loading overlay after 100 msec', () => {
            jasmine.clock().tick(105)
            expect(loadingStub.show).not.toHaveBeenCalled()
        });

        describe('after the request completes', () => {

            it('does not cancel the loading overlay', async () => {
                jasmine.clock().tick(105)
                await requestResult
                expect(loaderStub.hide).not.toHaveBeenCalled()
            });
        })
    });

    describe('when a request fails without a response', () => {

        beforeEach(async () => {
            axiosError = {error: "ERROR", request: {}};
            axiosStub.request.and.returnValue(Promise.reject(axiosError))

            requestResult = wrapper.vm.restRequest('api/endpoint', {
                method: 'post',
                params: {
                    foo: "foo"
                }
            });

            try {
                await requestResult
            } catch (e) {
                rethrownError = e
            }
        })

        it('displays the network error message', async () => {
            expect(wrapper.vm.showInErrorBar).toHaveBeenCalledWith('errors.network');
        });

        it('marks the request as not ongoing after the promise resolves', async () => {
            expect(wrapper.vm.requestOngoing).toBeFalse();
        })

        it('rethrows the error', () => {
            expect(rethrownError).toEqual(axiosError)
        });
    })

    describe('when a request fails without a response and a request', () => {

        beforeEach(async () => {
            axiosError = {error: "ERROR"};
            axiosStub.request.and.returnValue(Promise.reject(axiosError))

            requestResult = wrapper.vm.restRequest('api/endpoint', {
                method: 'post',
                params: {
                    foo: "foo"
                }
            });

            try {
                await requestResult
            } catch (e) {
                rethrownError = e
            }
        })

        it('displays a generic error message', async () => {
            expect(wrapper.vm.showInErrorBar).toHaveBeenCalledWith('errors.generic');
        });

        it('marks the request as not ongoing after the promise resolves', async () => {
            expect(wrapper.vm.requestOngoing).toBeFalse();
        })

        it('rethrows the error', () => {
            expect(rethrownError).toEqual({error: "ERROR"})
        });
    })

    describe('with error handling disabled', () => {

        describe('when a request fails without a response', () => {

            beforeEach(async () => {
                axiosError = {error: "ERROR", request: {}};
                axiosStub.request.and.returnValue(Promise.reject(axiosError))

                requestResult = wrapper.vm.restRequest('api/endpoint', {
                    method: 'post',
                    params: {
                        foo: "foo"
                    },
                    errorHandling: false
                });

                try {
                    await requestResult
                } catch (e) {
                    rethrownError = e
                }
            })

            it('does not display the network error message', async () => {
                expect(wrapper.vm.showInErrorBar).not.toHaveBeenCalled();
            });

            it('marks the request as not ongoing after the promise resolves', async () => {
                expect(wrapper.vm.requestOngoing).toBeFalse();
            })

            it('rethrows the error', () => {
                expect(rethrownError).toEqual(axiosError)
            });
        })
    })
});