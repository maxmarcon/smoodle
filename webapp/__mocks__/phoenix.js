export const joinMock = jest.fn()
export const pushMock = jest.fn()
export const onMock = jest.fn()
export const channelMock = jest.fn() 

export const Socket = jest.fn().mockImplementation(() => ({
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
    push: pushMock
  })
  channelMock.mockClear()
  joinMock.mockReturnValue(pushReturnValue)
  joinMock.mockClear()
  pushMock.mockReturnValue(pushReturnValue)
  pushMock.mockClear()
  onMock.mockClear()
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

resetMocks()
