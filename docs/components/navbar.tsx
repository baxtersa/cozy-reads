import Link from "next/link";
import Image from "next/image"
import logo from "@/public/img/CozyReads.png"

export default function Navbar() {
    const navigation = [
        {
            title: "Features",
            link: "/"
        },
        {
            title: "About",
            link: "/about"
        },
        {
            title: "Support",
            link: "/support"
        }
    ];

    return (
        <div className="w-full">
            <nav className="container relative flex flex-wrap items-center justify-between p-8 mx-auto lg:justify-between xl:px-0">
                {/* Logo  */}
                <div className="flex flex-wrap items-center justify-between w-full lg:w-auto">
                    <Link href="/">
                        <span className="flex items-center space-x-2 text-2xl font-medium text-gradientDark dark:text-gray-100">
                            <span>
                                <Image
                                    src={logo}
                                    alt="N"
                                    width="32"
                                    height="32"
                                    className="w-8"
                                />
                            </span>
                            <span>CozyReads</span>
                        </span>
                    </Link>
                </div>

                {/* menu  */}
                <div className="hidden text-center lg:flex lg:items-center">
                    <ul className="items-center justify-end flex-1 pt-6 list-none lg:pt-0 lg:flex">
                        {navigation.map((menu, index) => (
                            <li className="mr-3 nav__item" key={index}>
                                <Link href={menu.link} className="inline-block px-4 py-2 text-lg font-normal text-gray-800 no-underline rounded-md dark:text-gray-200 hover:text-gradientDark focus:text-gradientDark focus:bg-indigo-100 focus:outline-none dark:focus:bg-gray-800">
                                    {menu.title}
                                </Link>
                            </li>
                        ))}
                    </ul>
                </div>

                <div className="hidden mr-3 space-x-4 lg:flex nav__item">
                    <Link href="https://apps.apple.com/us/app/cozyreads/id6460936085" className="px-6 py-2 text-white bg-gradientDark rounded-md md:ml-5">
                        Download
                    </Link>
                </div>
            </nav>
        </div >
    );
}