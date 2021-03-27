const joinMock = jest.fn().mockReturnValue({
  receive: jest.fn().mockReturnThis()
})
export const pushMock = jest.fn().mockReturnValue({
  receive: jest.fn().mockReturnThis()
})
export const onMock = jest.fn().mockReturnThis()

export const Socket = jest.fn().mockImplementation(() => ({
  connect: jest.fn(),
  channel: jest.fn().mockReturnValue({
    join: joinMock,
    on: onMock,
    push: pushMock
  })
}))

export const setJoinResponse = (status, reply) => {
  joinMock.mockReturnValue({
    receive(_status, callback) {
      if (status === _status) {
        callback(reply)
      }
      return this
    }
  })
}

export const setPushResponse = (status, reply) => {
  pushMock.mockReturnValue({
    receive(_status, callback) {
      if (status === _status) {
        callback(reply)
      }
      return this
    }
  })
}