import SectionTitle from "@/components/sectionTitle";
import Container from "@/components/container";
import { Disclosure } from "@headlessui/react";
import { ChevronUpIcon } from "@heroicons/react/24/solid";

const faqdata = [
    {
        question: "What platforms does CozyReads support?",
        answer: " \
        CozyReads runs on most Apple platforms(iOS, iPadOS, and macOS). Other \
        platforms are not currently supported, but may be in the future. \
        ",
    },
    {
        question: "How does CozyReads handle star ratings?",
        answer: "CozyReads currently supports rating books in whole stars from 1-5."
    },
    {
        question: "How can I leave feedback for the developer?",
        answer: "If you have a Github account, opening an issue on the project page is the most direct way to leave feedback and get a response. Otherwise, please leave a review on the app store and we will try to respond!"
    },
    {
        question: "Why do only some books show a cover image?",
        answer: "Cover images are an experimental feature. We use the OpenLibrary API to retrieve covers when you use the search function and select a result when adding a book. Only books selected from these search results will currently display a cover image."
    }
];

export default function Support() {
    return (
        <>
            <SectionTitle pretitle="FAQ" title="Frequently Asked Questions">
                Common questions are answered below. Please open an Issue on the
                Github page for further support.
            </SectionTitle>
            <Container className="!p-0">
                <div className="w-full max-w-2xl p-2 mx-auto rounded-2xl">
                    {faqdata.map((item, index) => (
                        <div key={item.question} className="mb-5">
                            <Disclosure>
                                {({ open }) => (
                                    <>
                                        <Disclosure.Button className="flex items-center justify-between w-full px-4 py-4 text-lg text-left text-gray-800 rounded-lg bg-gray-50 hover:bg-gray-100 focus:outline-none focus-visible:ring focus-visible:ring-gray-100 focus-visible:ring-opacity-75 dark:bg-trueGray-800 dark:text-gray-200">
                                            {item.question}
                                            <ChevronUpIcon
                                                className={`${open ? "transform rotate-180" : "transform rotate-90"
                                                    } w-5 h-5 text-gradientDark`}
                                            />
                                        </Disclosure.Button>
                                        <Disclosure.Panel className="px-4 pt-4 pb-2 text-gray-500 dark:text-gray-300">
                                            {item.answer}
                                        </Disclosure.Panel>
                                    </>
                                )}
                            </Disclosure>
                        </div>)
                    )}
                </div>
            </Container>
        </>
    )
}