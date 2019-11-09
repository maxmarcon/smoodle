export default function wait(sec = 0) {
    return new Promise(resolve => {
        setTimeout(resolve, sec)
    })
}