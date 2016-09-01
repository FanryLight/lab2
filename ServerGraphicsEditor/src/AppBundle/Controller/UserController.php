<?php

namespace AppBundle\Controller;

use AppBundle\Entity\User;
use FOS\RestBundle\Controller\Annotations\RouteResource;
use FOS\RestBundle\Controller\FOSRestController;
use FOS\RestBundle\Controller\Annotations;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * @RouteResource("User", pluralize=false)
 */
class UserController extends FOSRestController
{

    /**
     * @param $username
     * @return bool
     */
    private function usernameIsValid($username)
    {
        $result = true;
        if (strlen($username) <= 3 || strlen($username) > 12)
        {
            $result = false;
        }
        else if (!ctype_alnum($username))
        {
            $result = false;
        }
        return $result;
    }

    /**
     * @param $password
     * @return bool
     */
    private function passwordIsValid($password)
    {
        $result = true;
        if (strlen($password) <= 5 || strlen($password) > 20)
        {
            $result = false;
        }
        return $result;
    }

    /**
     * @param $content
     * @return JsonResponse|Response
     */
    private function loginWithRequest($content)
    {
        $encodedPassword = md5($content['password']);
        $username = $content['username'];
        if (!$this->usernameIsValid($username))
        {
            $response = new JsonResponse();
            $response->setStatusCode(200);
            $response->setData(array('error' => 'Wrong data'));
            return $response;
        }

        $repository = $this->getDoctrine()->getRepository('AppBundle:User');
        $user = $repository->findOneBy(
            array('username' => $username, 'password' => $encodedPassword)
        );
        if (!$user)
        {
            $response = new JsonResponse();
            $response->setStatusCode(200);

            $response->setData(array('error' => 'Wrong data'));
            return $response;
        }
        else
        {
            $apikey = $user->getApikey();
            $response = new JsonResponse();
            $response->setStatusCode(200);
            $response->setData(array('apikey' => $apikey));
            return $response;
        }
    }

    /**
     * @param $content
     * @return JsonResponse|Response
     */
    private function registrationWithRequest($content)
    {
        $username = $content['username'];
        $password = $content['password'];
        if ($this->usernameIsValid($username) && $this->passwordIsValid($password))
        {
            $repository = $this->getDoctrine()->getRepository('AppBundle:User');
            $user = $repository->findOneBy(
            array('username' => $username));
            if ($user)
            {
                $response = new JsonResponse();
                $response->setStatusCode(200);
                $response->setData(array('error' => 'Username is already taken'));
                return $response;
            }
            $user = new User();
            $user->setUsername($username);
            $user->setPassword($password);
            $em = $this->getDoctrine()->getManager();
            $em->persist($user);
            $em->flush();
            $apikey = $user->getApikey();

            $response = new JsonResponse();
            $response->setStatusCode(200);
            $response->setData(array('apikey' => $apikey));
            return $response;
        }
        else
        {
            $response = new JsonResponse();
            $response->setStatusCode(200);
            $response->setData(array('error' => 'Wrong data'));
            return $response;
        }
    }

    /**
     * @param $action
     * @param Request $request
     * @return \Symfony\Component\HttpFoundation\Response
     */
    public function postAction($action, Request $request)
    {
        if ($request->getContentType() != "json")
        {
            $response = new Response();
            $response->setStatusCode(415);  //Unsupported Media Type
            return $response;
        }
        $content = json_decode($request->getContent(), true);
        if (!isset($content['username']) || !isset($content['password']))
        {
            $response = new Response();
            $response->setStatusCode(400);  //Bad Request
            return $response;
        }
        if ($action == 'login')
        {
            return $this->loginWithRequest($content);
        }
        else if ($action == 'registration')
        {
            return $this->registrationWithRequest($content);
        }
        else
        {
            $response = new Response();
            $response->setStatusCode(405);   //Method Not Allowed
            return $response;
        }
    }
}