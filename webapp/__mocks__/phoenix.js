export const joinMock = jest.fn()
export const pushMock = jest.fn()
export const onMock = jest.fn()
export const channelMock = jest.fn()
export const leaveMock = jest.fn()

const DEFAULT_EVENT_DELAY = 10

export const Socket = jest.fn(() => ({
  connect: jest.fn(),
  channel: channelMock
}))

export const resetMocks = () => {
  const pushReturnValue = {
    receive: jest.fn().mockReturnThis()
  }

  channelMock.mockReturnValue({
    join: joinMock,
    on: onMock,
    push: pushMock,
    leave: leaveMock
  })
  channelMock.mockClear()
  joinMock.mockReturnValue(pushReturnValue)
  joinMock.mockClear()
  pushMock.mockReturnValue(pushReturnValue)
  pushMock.mockClear()
  onMock.mockReset()
  leaveMock.mockReset()
}

const setResponse = (mock, status, reply) => {
  mock.mockReturnValue({
    receive(_status, callback) {
      if (status === _status) {
        callback(reply)
      }
      return this
    }
  })
}

export const setJoinResponse = (status, reply) => setResponse(joinMock, status, reply)

export const setPushResponse = (status, reply) => setResponse(pushMock, status, reply)

export const sendEvent = (event, payload, delay = DEFAULT_EVENT_DELAY) => onMock.mockImplementation((_event, callback) => {
  if (_event === event) {
    setTimeout(() => callback(payload), delay)
  }
})

resetMocks()
