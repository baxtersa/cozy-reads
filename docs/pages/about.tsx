import Container from "@/components/container"

const data = {
    title: "About the project",
    desc: "CozyReads began as a handwritten list of books, then a spreadsheet \
    and an exploration of Apple Numbers charting features, and ultimately became \
    a mobile application to fill the author's journey to find enjoyment in \
    software development.",
    story: "It is primarily built on a modern iOS tech stack using \
    SwiftUI, CoreData/CloudKit, and other tools that the author has found \
    interesting to learn about."
}

export default function About() {
    return (
        <>
            <Container className="flex flex-wrap mb-20 lg:gap-10 lg:flex-nowrap ">
                <div className={`flex flex-wrap items-center w-full`}>
                    <div>
                        <div align="center" className="flex flex-col w-full mt-4">
                            <h1 className="text-4xl font-bold leading-snug tracking-tight text-gray-800 lg:text-4xl lg:leading-tight xl:text-6xl xl:leading-tight dark:text-white">
                                {data.title}
                            </h1>

                            <p className="py-5 text-xl leading-normal text-gray-500 lg:text-xl xl:text-2xl dark:text-gray-300">
                                {data.desc}
                            </p>

                            <h3 className="max-w-2xl mt-3 text-3xl font-bold leading-snug tracking-tight text-gray-800 lg:leading-tight lg:text-4xl dark:text-white">
                                Development
                            </h3>
                            <p className="max-w-2xl py-4 text-lg leading-normal text-gray-500 lg:text-xl xl:text-xl dark:text-gray-300">
                                {data.story}
                            </p>
                        </div>
                    </div>
                </div>
            </Container>
        </>
    )
}
