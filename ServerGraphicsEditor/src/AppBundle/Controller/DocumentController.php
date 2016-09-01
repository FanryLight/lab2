<?php

namespace AppBundle\Controller;

use AppBundle\Entity\Document;
use FOS\RestBundle\Controller\Annotations\RouteResource;
use FOS\RestBundle\Controller\FOSRestController;
use FOS\RestBundle\Controller\Annotations;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

/**
 * @RouteResource("Document", pluralize=false)
 */
class DocumentController extends FOSRestController
{
    function getUserByApikey($apikey)
    {
        return $this->getDoctrine()->getManager()->getRepository('AppBundle:User')->findOneBy(array('apikey' => $apikey));
    }

    /**
     * @param $author
     * @return JsonResponse|Response
     */
    private function uploadWithFiles($author)
    {
        if (!isset($_POST["name"]) || !isset($_FILES["document"]) || !isset($_FILES["image"]))
        {
            $response = new JsonResponse();
            $response->setData(array('error' => 'Wrong data!'));
            return $response;
        }
        if ($_FILES["image"]["error"] == UPLOAD_ERR_OK && $_FILES["document"]["error"] == UPLOAD_ERR_OK)
        {
            $extension = explode('.', $_FILES["document"]["name"]);
            //var_dump($extension);
            if (($_FILES["image"]["type"] != "image/jpeg" && $_FILES["image"]["type"] != "image/png")
                || $extension[1] !== "drg")
            {
                $response = new JsonResponse();
                $response->setData(array('error' => 'Wrong data!'));
                return $response;
            }
            else
            {
                $name = htmlspecialchars($_POST["name"], ENT_QUOTES);;
                $imagePath = $name.".jpg";
                $documentPath = $name.".drg";

                $document = new Document();
                $document->setAuthor($author);
                $document->setImagePath($imagePath);
                $document->setDocumentPath($documentPath);
                $document->setName($name);
                $document->generateFileName();

                $file = $_FILES["document"]["tmp_name"];
                $image = $_FILES["image"]["tmp_name"];
                move_uploaded_file($file, $document->getUploadDir().$document->getDocumentPath());
                move_uploaded_file($image, $document->getUploadDir().$document->getImagePath());

                $em = $this->getDoctrine()->getManager();
                $em->persist($document);
                $em->flush();

                $response = new Response();
                $response->setStatusCode(200);
                return $response;
            }
        }
        else
        {
            $response = new JsonResponse();
            $response->setData(array('error' => 'Data size is bigger than 50M!'));
            return $response;
        }

    }

    /**
     * @param Request $request
     * @param $author
     * @return JsonResponse|Response
     */
    private function uploadWithRequest(Request $request, $author)
    {
        if (!$request->files->get("image")|| !$request->files->get("document") || !$request->request->get("name"))
        {
            $response = new JsonResponse();
            $response->setData(array('error' => 'Wrong data!'));
            return $response;
        }
        if ($request->files->get('image')->getError() == UPLOAD_ERR_OK && $request->files->get('document')->getError() == UPLOAD_ERR_OK)
        {
            $docExtension = $request->files->get('document')->getClientOriginalExtension();
            $imageExtension = $request->files->get('image')->getClientOriginalExtension();
            if ($docExtension == 'drg' && ($imageExtension == 'jpg' || $imageExtension == 'png'))
            {
                $image = $request->files->get('image');
                $file = $request->files->get('document');
                $name = htmlspecialchars($request->request->get("name"), ENT_QUOTES);
                $document = new Document();
                $document->setAuthor($author);
                $document->setImage($image);
                $document->setDocument($file);
                $document->setName($name);
                $document->upload();

                $em = $this->getDoctrine()->getManager();
                $em->persist($document);
                $em->flush();
                $response = new Response();
                $response->setStatusCode(200);
                return $response;
            }
            else
            {
                $response = new JsonResponse();
                $response->setData(array('error' => 'Wrong data!'));
                return $response;
            }
    }
        else
        {
            $response = new JsonResponse();
            $response->setData(array('error' => 'Data size is bigger than 50M!'));
            return $response;
        }
    }

    /**
     * @param Request $request
     * @return Response
     */
    public function postAction(Request $request)
    {
        if (!$request->request->get("apikey"))
        {
            $author = $this->getUserByApikey($request->request->get("apikey"));
            if ($author)
            {
                return $this->uploadWithRequest($request, $author);
            }
            else
            {
                $response = new Response();
                $response->setStatusCode(401);  //Unauthorized
                return $response;
            }
        }
        else if (isset($_POST["apikey"]))
        {
            $author = $this->getUserByApikey($_POST["apikey"]);
            if ($author)
            {
                return $this->uploadWithFiles($author);
            }
            else
            {
                $response = new Response();
                $response->setStatusCode(401);  //Unauthorized
                return $response;
            }
        }
        else
        {
            $response = new Response();
            $response->setStatusCode(401);  //Unauthorized
            return $response;
        }
    }

    /**
     * @param Request $request
     * @return JsonResponse|Response
     */
    public function cgetAction(Request $request)
    {
        if ($request->headers->get('apikey'))
        {

            $author = $this->getUserByApikey($request->headers->get("apikey"));
            if ($author)
            {
                $repository = $this->getDoctrine()->getManager()->getRepository("AppBundle:Document");
                $documents = $repository->findBy(array('author' => $author));
                $host = $request->headers->get('host');
                $array = array();
                for($i = 0; $i < count($documents); $i++)
                {
                    $row = array();
                    $row["id"] = $documents[$i]->getId();
                    $row["image"] = $host.$documents[$i]->getWebImagePath();
                    $row["document"] = $host.$documents[$i]->getWebDocumentPath();
                    $row["name"] = $documents[$i]->getName();
                    $array[$i] = $row;
                }
                $response = new JsonResponse();
                $response->setData(array('array' => $array));
                return $response;
            }
            else
            {
                $response = new Response();
                $response->setStatusCode(401);  //Unauthorized
                return $response;
            }
        }
        else
        {
            $response = new Response();
            $response->setStatusCode(401);  //Unauthorized
            return $response;
        }

    }

    /**
     * @param Request $request
     * @return Response
     */
    public function deleteAction(Request $request)
    {
        if ($request->request->get('apikey'))
        {
            $author = $this->getUserByApikey($request->request->get("apikey"));
            if ($author)
            {
                $id = $request->request->get('id');
                if ($id)
                {
                    $repository = $this->getDoctrine()->getManager()->getRepository("AppBundle:Document");
                    $document = $repository->findOneBy(array('id' => $id));
                    if ($document->getAuthor() === $author)
                    {
                        unlink($document->getUploadDir().$document->getDocumentPath());
                        unlink($document->getUploadDir().$document->getImagePath());
                        $em = $this->getDoctrine()->getManager();
                        $em->remove($document);
                        $em->flush();

                        $response = new Response();
                        $response->setStatusCode(200);
                        return $response;
                    }
                    else
                    {
                        $response = new Response();
                        $response->setStatusCode(406);  // Not Acceptable
                        return $response;
                    }
                }
                else
                {
                    $response = new Response();
                    $response->setStatusCode(400);  //Bad Request
                    return $response;
                }
            }
            else
            {
                $response = new Response();
                $response->setStatusCode(401);  //Unauthorized
                return $response;
            }
        }
        else
        {
            $response = new Response();
            $response->setStatusCode(401);  //Unauthorized
            return $response;
        }
    }

}