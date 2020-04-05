import RestMixin from '@/mixins/rest'
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
    jest.useFakeTimers()

    axiosStub = {
      request: jest.fn()
    }
    showInErrorBarStub = jest.fn();
    loaderStub = {
      hide: jest.fn()
    }
    loadingStub = {
      show: jest.fn().mockReturnValue(loaderStub)
    }

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
    jest.useRealTimers()
  })

  it('has an API version', () => {
    expect(wrapper.vm.apiVersion).toBeTruthy()
  });

  it('initially there is no ongoing request', () => {
    expect(wrapper.vm.requestOngoing).toBeFalsy()
  });

  describe('when executing a request', () => {

    beforeEach(() => {
      axiosStub.request.mockReturnValue(
        new Promise((resolve) => setTimeout(() => resolve("RESPONSE"), 105))
      )

      requestResult = wrapper.vm.restRequest('api/endpoint', {
        method: 'post',
        params: {
          foo: "foo"
        }
      });
    })

    it('calls axios with the right parameters', () => {
      expect(axiosStub.request).toHaveBeenCalledWith(expect.objectContaining({
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

    it('returns a promise', () => {
      expect(requestResult).toEqual(expect.any(Promise));
    });

    it('marks the request as ongoing', () => {
      expect(wrapper.vm.requestOngoing).toBeTruthy();
    });

    it('shows the loading overlay after 100 msec', () => {
      jest.advanceTimersByTime(100)
      expect(loadingStub.show).toHaveBeenCalled()
    });

    describe('after the request completes', () => {

      beforeEach(() => jest.advanceTimersByTime(105))

      it('the returned promise resolves to the response', async () => {
        const response = await requestResult
        expect(response).toEqual("RESPONSE")
      })

      it('marks the request as not ongoing', async () => {
        await requestResult;
        expect(wrapper.vm.requestOngoing).toBeFalsy();
      })

      it('cancels the loading overlay', async () => {
        await requestResult
        expect(loaderStub.hide).toHaveBeenCalled()
      });
    })
  })

  describe('for background requests', () => {

    beforeEach(() => {
      axiosStub.request.mockReturnValue(
        new Promise((resolve) => setTimeout(() => resolve("RESPONSE"), 105))
      )

      requestResult = wrapper.vm.restRequest('api/endpoint', {
        method: 'post',
        params: {
          foo: "foo"
        },
        background: true
      });
    })

    it('does not mark the request as ongoing', () => {
      expect(wrapper.vm.requestOngoing).toBeFalsy();
    });

    it('does not show the loading overlay after 100 msec', () => {
      jest.advanceTimersByTime(100)
      expect(loadingStub.show).not.toHaveBeenCalled()
    });

    describe('after the request completes', () => {

      beforeEach(() => jest.advanceTimersByTime(105))

      it('the request is still not marked as ongoing', async () => {
        await requestResult;
        expect(wrapper.vm.requestOngoing).toBeFalsy();
      })

      it('does not cancel the loading overlay', async () => {
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

      axiosStub.request.mockReturnValue(
        new Promise((resolve) => setTimeout(() => resolve("RESPONSE"), 105))
      )

      requestResult = wrapper.vm.restRequest('api/endpoint', {
        method: 'post',
        params: {
          foo: "foo"
        }
      });
    })

    it('does not show the loading overlay after 100 msec', () => {
      jest.advanceTimersByTime(100)
      expect(loadingStub.show).not.toHaveBeenCalled()
    });

    describe('after the request completes', () => {

      beforeEach(() => jest.advanceTimersByTime(105))

      it('does not cancel the loading overlay', async () => {
        await requestResult
        expect(loaderStub.hide).not.toHaveBeenCalled()
      });
    })
  });

  describe('when a request fails without a response', () => {

    beforeEach(async () => {
      axiosError = {error: "ERROR", request: {}};
      axiosStub.request.mockRejectedValue(axiosError)

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

    it('displays the network error message', () => {
      expect(wrapper.vm.showInErrorBar).toHaveBeenCalledWith('errors.network');
    });

    it('marks the request as not ongoing after the promise resolves', () => {
      expect(wrapper.vm.requestOngoing).toBeFalsy();
    })

    it('rethrows the error', () => {
      expect(rethrownError).toEqual(axiosError)
    });
  })

  describe('when a request fails without a response and a request', () => {

    beforeEach(async () => {
      axiosError = {error: "ERROR"};
      axiosStub.request.mockRejectedValue(axiosError)

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

    it('displays a generic error message', () => {
      expect(wrapper.vm.showInErrorBar).toHaveBeenCalledWith('errors.generic');
    });

    it('marks the request as not ongoing after the promise resolves', () => {
      expect(wrapper.vm.requestOngoing).toBeFalsy();
    })

    it('rethrows the error', () => {
      expect(rethrownError).toEqual({error: "ERROR"})
    });
  })

  describe('with error handling disabled', () => {

    describe('when a request fails without a response', () => {

      beforeEach(async () => {
        axiosError = {error: "ERROR", request: {}};
        axiosStub.request.mockRejectedValue(axiosError)

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

      it('does not display the network error message', () => {
        expect(wrapper.vm.showInErrorBar).not.toHaveBeenCalled();
      });

      it('marks the request as not ongoing after the promise resolves', () => {
        expect(wrapper.vm.requestOngoing).toBeFalsy();
      })

      it('rethrows the error', () => {
        expect(rethrownError).toEqual(axiosError)
      });
    })
  })
});
